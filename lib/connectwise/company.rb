require 'securerandom'

module Connectwise
  class Company
    include Model
    plural :companies
    attr_accessor :id, :status, :type, :market, :territory, :web_site, :fax_number, :phone_number, :company_name, :company_id

    def self.where_transform(attrs)
      attrs[:company_name] ||= attrs.delete(:name) if attrs[:name]
      attrs
    end

    def self.transform(attrs)
      attrs[:company_name] ||= attrs.delete(:name)
      attrs[:status] ||= 'Active'
      attrs[:company_id] ||= SecureRandom.hex(12)
      attrs
    end

    def self.find_transform(attrs)
      attrs[:id] ||= attrs.delete(:company_rec_id)
      attrs
    end

    def self.save_transform(attrs)
      attrs[:id] ||= attrs.delete(:company_rec_id)
      attrs
    end

    def to_cw_h
      attrs = super
      attrs['CompanyID'] = attrs.delete('CompanyId')
      attrs
    end
  end
end
