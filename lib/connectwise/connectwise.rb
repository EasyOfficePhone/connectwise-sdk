module Connectwise
  class ConnectionError < StandardError; end
  class UnknownHostError < ConnectionError; end
  class UnknownCompanyError < ConnectionError; end
  class BadCredentialsError < ConnectionError; end

  class Connection
    attr_reader :host, :custom_api_mapping
    attr_accessor :log

    def initialize(host: '', company_name: '', integrator_login_id: '', integrator_password: '', custom_api_mapping: {})
      @custom_api_mapping = custom_api_mapping
      @host = host
      @credentials = {CompanyId: company_name, IntegratorLoginId: integrator_login_id, IntegratorPassword: integrator_password}
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
          raise ConnectionError.new "An unknown error occurred when contacting Connectwise"
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
      api =~ /Api\z/ ? api : "#{camelize(api)}Api"
    end

    def camelize(term)
      string = term.to_s.sub(/^[a-z\d]*/) { $&.capitalize }
      string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
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

  module Model
    def initialize(**attributes)
      attributes.each do |attr, value|
        public_send "#{attr}=", value
      end
    end
  end

  class Client
    include Model
    attr_accessor :first_name, :last_name, :email_address
  end

  class Company
    include Model
    attr_accessor :company_name, :url
  end

  class Opportunity
    include Model

  end

  class ServiceTicket
    include Model

  end

  class BaseAPI
    attr_reader :connection
    def initialize(connection)
      @connection = connection
    end

    # Members
    def find_member(user, &err_handler)
      resp = connection.call 'MemberApi', :find_members, {conditions: "EmailAddress like '#{user.email}'"}, &err_handler
      (result = resp[:member_find_result]) ? Array(result) : resp
    end

    # Contact
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

    # Companies
    def find_company(company, &err_handler)
      resp = connection.call 'CompanyApi', :find_companies, { conditions: "CompanyName like '%#{company.name}%' or CompanyID = '#{company.id}'" }, &err_handler
      (result = resp[:company_find_result]) ? Array(result) : resp
    end

    def create_company(company, &err_handler)
      message = {
        Id: 0,
        CompanyName: company.name,
        CompanyID: company.id.to_s,
        WebSite: company.url,
        Status: 'Active',
      }
      connection.call 'CompanyApi', :add_company, {company: message}, &err_handler
    end

    def delete_company(company, &err_handler)
      connection.call 'CompanyApi', :delete_company, {id: company.id}, &err_handler
    end

    # Opportunity
    def create_opportunity(opportunity, company_id, contact_id, &err_handler)
      message = {
        Id: 0,
        OpportunityName: "Opportunity from Easyofficephone - #{opportunity.company.name}",
        Company: {CompanyID: company_id},
          Contact: {Id: contact_id},
          Source: 'Easy Office Phone opportunity',
          PrimarySalesRep: opportunity.user.full_name,
          Notes: {
          Note: {
          note_text: opportunity.note,
        }
        },
      }

        connection.call 'OpportunityApi', :add_opportunity, {opportunity: message}, &err_handler
    end

    def delete_opportunity(opportunity, &err_handler)
      connection.call 'OpportunityApi', :delete_opportunity, {id: opportunity.id}, &err_handler
    end

    # Ticket
    #TODO - these find methods are too limited, need to allow proper query
    def find_ticket(ticket, company)
      resp = connection.call 'ServiceTicketApi', :find_service_tickets, {conditions: "CompanyName like '%#{company.name}%' or SRServiceRecID = '#{ticket.id}'"}
      (result = resp[:tickets]) ? Array(result) : resp
    end

    def create_ticket(ticket, company, &err_handler)
      resp = connection.call 'ServiceTicketApi', :add_service_ticket_via_company_id, {
        serviceTicket: {
        Id: 0,
        CompanyId: company.id,
        Summary: ticket.subject,
        Status: 'N',
        ProblemDescription: ticket.description,
      }
      }, &err_handler
    end
  end
end
