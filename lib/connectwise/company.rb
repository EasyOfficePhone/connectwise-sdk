require 'securerandom'

module Connectwise
  class Company
    include Model
    plural :companies
    attr_accessor :id, :status, :type, :market, :territory, :web_site, :fax_number, :phone_number, :company_name, :company_id

    def self.transform(attrs)
      attrs[:company_name] ||= attrs.delete(:name)
      attrs
    end

    def initialize(connection, attrs)
      super
      @company_id ||= SecureRandom.hex(12)
    end

    private
    def to_cw_h
      attrs = super
      attrs['CompanyID'] = attrs.delete('CompanyId')
      attrs
    end
  end
end
