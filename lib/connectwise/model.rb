module Connectwise
  module Model
    module ClassMethods
      def where(connection, *args, **attrs)
        conditions = attrs.empty? ? args.join(' ') : attrs_to_query(transform(attrs))
        resp = connection.call cw_api_name, "find_#{plural_class_name}".to_sym, {conditions: conditions}
        resp ? Array(remove_root_node(resp)).map {|attrs| self.new(connection, find_transform(attrs)) } : []
      end

      def find(connection, id)
        if (attrs = connection.call(cw_api_name, "get_#{cw_api_name}".to_sym, {id: id}))
          self.new(connection, find_transform(attrs))
        else
          fail RecordNotFound
        end
      rescue ConnectionError
        raise RecordNotFound
      end

      def plural(plural)
        @plural_form = plural
      end

      def attrs_to_query(attrs)
        attrs.map do |k,v|
          str = k.to_s
          str.extend(Connectwise::Extensions::String)
          "#{str.camelize} like '#{v}'"
        end.join(' and ')
      end

      def cw_api_name
        base_class_name.downcase.to_sym
      end

      def plural_class_name
        ending = base_class_name[/[aeiou]$/] ? 'es' : 's'
        @plural_form ||= "#{base_class_name.downcase}#{ending}"
      end

      def find_transform(attrs)
        attrs
      end

      def save_transform(attrs)
        attrs
      end

      def transform(attrs)
        attrs
      end

      def model_name(model_name = self.name)
        @model_name ||= model_name
      end

      private
      def base_class_name
        model_name.split('::').last
      end

      def remove_root_node(resp)
        resp.values.first
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def initialize(connection, **attributes)
      @connection = connection
      self.class.transform(attributes).each do |attr, value|
        public_send("#{attr}=", value) if respond_to?("#{attr}=")
      end
    end

    def save
      attrs = connection.call self.class.cw_api_name, "add_or_update_#{self.class.cw_api_name}".to_sym, {self.class.cw_api_name => to_cw_h}
      self.class.new(connection, self.class.save_transform(attrs))
    end

    def destroy
      connection.call self.class.cw_api_name, "delete_#{self.class.cw_api_name}".to_sym, {id: id}
      self
    end

    def persisted?
      !!id
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
