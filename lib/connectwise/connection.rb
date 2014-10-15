module Connectwise
  class Connection
    attr_reader :host, :custom_api_mapping
    attr_accessor :log

    def initialize(host: '', company_name: '', integrator_login_id: '', integrator_password: '', custom_api_mapping: {})
      @custom_api_mapping = custom_api_mapping
      @host = host
      @credentials = {CompanyId: company_name, IntegratorLoginId: integrator_login_id, IntegratorPassword: integrator_password}
      HTTPI.adapter = :net_http
    end

    def call(api, action, message, options: {}, &err_handler)
      err_handler ||= proc {|err| raise err}

      client = Savon.client(default_options.merge(options).merge(wsdl: wsdl_url(api)))
      response = client.call action, message: credentials.merge(message)
      response.body["#{action}_response".to_sym]["#{action}_result".to_sym]
    rescue Savon::SOAPFault, Savon::UnknownOperationError, SocketError, URI::InvalidURIError => err
      begin
        case err.message
        when /username or password is incorrect/i
          raise BadCredentialsError.new 'Login or Password are incorrect'
        when /hostname nor servname/i
          raise UnknownHostError.new "The host (#{@host}) is not reachable"
        when /cannot find company.*connectwise config/i
          raise UnknownCompanyError.new "The company (#{@credentials[:CompanyId]}) cannot be found by Connectwise"
        else
          raise ConnectionError.new "An unknown error occurred when contacting Connectwise : \n#{err.message}"
        end
      rescue BadCredentialsError, UnknownHostError, UnknownCompanyError, ConnectionError => err
        err_handler.call(err)
      end
    end

    private
    def default_options
      defaults = { convert_request_keys_to: :none, ssl_verify_mode: :none }
      defaults = defaults.merge({ log: true, pretty_print_xml: true }) if @log
      defaults
    end

    def wsdl_url(api_name)
      "https://#{host}/v4_6_release/apis/1.5/#{api(api_name)}.asmx?wsdl"
    end

    def credentials
      {credentials: @credentials}
    end

    def api(desired_api)
      api = api_mapping.fetch(desired_api) {desired_api}.to_s
      api.extend(Connectwise::Extensions::String)
      api =~ /Api\z/ ? api : "#{api.camelize}Api"
    end

    def api_mapping
      {
        billing: :generic_billing_transaction,
        config: :configuration,
        device: :managed_device,
        ticket: :service_ticket,
      }.merge(custom_api_mapping)
    end
  end
end
