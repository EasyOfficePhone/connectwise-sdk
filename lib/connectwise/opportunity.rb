module Connectwise
  class Opportunity
    include Model
    plural :opportunities

    attr_accessor :id, :opportunity_name, :source, :rating, :stage_name, :type, :status, :closed, :won, :lost, :close_probablity, :expected_close_date, :primary_sales_rep, :secondary_sales_rep,
      :marketing_campaign_name, :location, :business_unit, :age, :estimated_total, :recurring_total, :won_amount, :lost_amount, :open_amount, :margin, :product_amount, :service_amount

    def company=(company)
      @company = company
    end

    def contact=(contact)
      @contact = contact
    end

    def company_id
      @company
    end

    private

    def to_cw_h
      attrs = super
      attrs.delete('CompanyId')
      attrs.delete('ContactId')
      attrs['Company'] = {'CompanyID' => @company.company_id} if @company
      attrs['Contact'] = {'Id' => @contact.id} if @contact
      attrs
    end

    def self.transform(attrs)
      name = attrs.delete(:name) || attrs.delete(:opportunity_name)
      attrs[:opportunity_name] = name if name
      attrs
    end

    def self.where_transform(attrs)
      name = attrs.delete(:name) || attrs.delete(:opportunity_name)
      attrs[:opportunity_name] = name if name
      attrs
    end
  end
end
