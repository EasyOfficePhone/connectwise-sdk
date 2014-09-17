module Connectwise
  module Model
    module ClassMethods
      def attrs_to_query(attrs)
        attrs.map do |k,v|
          str = k.to_s
          str.extend(Connectwise::Extensions::String)
          "#{str.camelize} like '#{v}'"
        end.join(' and ')
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def initialize(connection, **attributes)
      @connection = connection
      attributes.each do |attr, value|
        public_send "#{attr}=", value
      end
    end

    def persisted?
      false
    end

    def to_h
      defined_attributes.each_with_object({}) {|name, memo| memo[name] = public_send(name)}
    end

    def to_cw_h
      defined_attributes.each_with_object({}) {|name, memo| key = name.to_s.extend(Extensions::String); memo[key.camelize] = public_send(name)}
    end

    def defined_attributes
      instance_vars = instance_variables.map {|name| name.to_s.gsub(/@/, '').to_sym}
      public_methods.select{|method| instance_vars.include?(method) }
    end
    protected
    def connection
      @connection
    end
  end
end
