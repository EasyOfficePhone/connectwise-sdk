module Connectwise
  class Contact
    include Model
    #TODO - email or email_address - Member uses email_address, while here it's email - normalize
    attr_accessor :id, :first_name, :last_name, :company_name, :phone, :email, :type, :relationship, :default_flag, :address_line1, :address_line2, :city, :state, :zip, :country,
      :portal_security_level, :portal_security_caption, :disable_portal_login, :last_update

    def self.where(connection, **attrs)
      resp = connection.call :contact, :find_contacts, {conditions: attrs_to_query(attrs)}
      Array(resp[:contact_find_result]).map {|attrs| cw_find_to_model(connection, attrs) }
    end

    def save
      #message = message.merge(CompanyId: company_id) if company_id
      attrs = connection.call 'ContactApi', :add_or_update_contact, {contact: to_cw_h}
      p attrs
      self.class.cw_to_model(connection, attrs)
    end

    def destroy

    end

    def persisted?
      !!@id
    end

    private
    def self.cw_find_to_model(conn, attrs)
      id = attrs.delete(:contact_rec_id)
      #TODO - make use of company rec id - either run another query to create it, or find a way to defer until company is asked for
      company_id = attrs.delete(:company_rec_id)
      self.new(conn, id: id, **attrs)
    end

    def self.cw_save_to_model(conn, attrs)

    end

    def create_contact(contact, company_id=nil, &err_handler)
      message = {
        FirstName: contact.first_name,
        LastName: contact.last_name,
        Email: contact.email,
        Phone: contact.phone,
      }
      message = message.merge(CompanyId: company_id) if company_id
      connection.call 'ContactApi', :add_or_update_contact, {contact: message}, &err_handler
    end

    def delete_contact(contact, &err_handler)
      connection.call 'ContactApi', :delete_contact, {id: contact.id}, &err_handler
    end

  end
end
