require 'json'

module Connectwise
  class Ticket
    include Model
    model_name 'service_ticket'
    attr_accessor :id, :summary, :problem_description, :status_name, :board, :site_name, :status, :resolution, :remote_internal_company_name, :priority, :source, :severity, :impact, :company, :company_id, :closed_flag, :member_id, :member_rec_id, :notes

    #TODO - The use of SrServiceRecid and TicketNumber instead of id - may want to configure these
    # but this is so inconsistent for tickets that it may not be worth it unless other calls do the same thing
    def self.find(connection, id)
      if (attrs = connection.call(cw_api_name, "get_#{cw_api_name}".to_sym, {ticketNumber: id}))
        self.new(connection, find_transform(attrs))
      else
        fail RecordNotFound
      end
    rescue ConnectionError
      raise RecordNotFound
    end

    def self.parse(connection, params)
      resp = JSON.parse(params.keys.first)
      ticket_info = JSON.parse(resp['Entity'])
      self.new(connection, id: params[:id], summary: ticket_info['Summary'], closed_flag: ticket_info['ClosedFlag'], severity: ticket_info['Severity'], company_id: ticket_info['CompanyId'], member_id: ticket_info['memberId'])
    end

    def status_name
      @status_name ||= 'New'
    end

    def save
      return false unless @company
      attrs = {companyId: @company.company_id, 'serviceTicket' => to_cw_h}
      attrs = connection.call self.class.cw_api_name, "add_or_update_#{self.class.cw_api_name}_via_company_id".to_sym, attrs
      self.class.new(connection, self.class.save_transform(attrs))
    end

    def destroy
      connection.call self.class.cw_api_name, "delete_#{self.class.cw_api_name}".to_sym, {ticketNumber: id}
      self
    end

    def add_note(msg, **options)
      note = TicketNote.new(connection, {note: msg, ticket: self}.merge(options))
      note.save
    end

    private
    def self.find_transform(attrs)
      attrs[:id] = attrs.delete(:ticket_number) || attrs.delete(:sr_service_rec_id)
      notes = normalize_find_response(attrs[:detail_notes]) + normalize_find_response(attrs[:internal_notes]) + normalize_find_response(attrs[:resolution_notes])
      attrs[:notes] = notes.compact.map do |note|
        TicketNote.new(@connection, **note)
      end
      attrs
    end

    def self.save_transform(attrs)
      attrs[:id] = attrs.delete(:ticket_number)
      attrs[:company] = OpenStruct.new id: attrs.delete(:company_rec_id)
      attrs
    end

    def to_cw_h
      attrs = super
      attrs.delete('Company')
      attrs['TicketNumber'] = attrs[:id] || 0
      attrs
    end
  end
end
