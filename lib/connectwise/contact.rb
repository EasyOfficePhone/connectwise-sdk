module Connectwise
  class Contact
    include Model
    #TODO - email or email_address - Member uses email_address, while here it's email - normalize
    attr_accessor :id, :first_name, :last_name, :company_name, :phone, :email, :type, :relationship, :default_flag, :address_line1, :address_line2, :city, :state, :zip, :country,
      :portal_security_level, :portal_security_caption, :disable_portal_login, :last_update, :company_id

    #TODO - add company accessor and make use of company rec id - either run another query to create it, or find a way to defer until company is asked for
    def company=(company)
      @company = company
    end

    private
    def self.find_transform(attrs)
      attrs[:id] ||= attrs.delete(:contact_rec_id)
      attrs
    end

    def self.save_transform(attrs)
      attrs[:id] ||= attrs.delete(:contact_rec_id)
      attrs
    end

    def to_cw_h
      h = super
      h.delete(:company_id)
      h = h.merge(CompanyId: @company.company_id) if @company
      h
    end
  end
end
