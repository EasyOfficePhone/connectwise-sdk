module Connectwise
  class TicketNote
    include Model
    model_name 'ticket_note'
    attr_accessor :id, :note, :note_text, :is_part_of_internal_analysis, :is_part_of_resolution, :is_part_of_detail_description

    def self.cw_api_name
      :service_ticket
    end

    def self.transform(attrs)
      type = attrs.delete(:type)
      attrs[:note_text] ||= attrs.delete(:note)
      if type == :internal
        attrs[:is_part_of_internal_analysis] = true
      elsif type == :resolution
        attrs[:is_part_of_resolution] = true
      else
        attrs[:is_part_of_detail_description] = true
      end
      attrs
    end

    def initialize(connection, **attributes)
      @ticket = attributes.delete(:ticket)
      super(connection, attributes)
    end

    def save
      attrs = connection.call self.class.cw_api_name, "update_#{self.class.cw_model_name}".to_sym, {'note' => to_cw_h, 'srServiceRecid' => @ticket.id}
      self.class.new(connection, self.class.save_transform(attrs))
    end

    def external?
      !!is_part_of_detail_description
    end

    def internal?
      !!is_part_of_internal_analysis
    end

    def resolution?
      !!is_part_of_resolution
    end
  end
end
