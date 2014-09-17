require 'spec_helper'

describe Connectwise::Connection do
  let(:credentials) { connectwise_credentials }
  subject { Connectwise::Connection.new(credentials) }

  describe 'Failures' do
    it 'raises an UnknownHostError' do
      subject = Connectwise::Connection.new(credentials.merge(host: 'badhost.connectwisebad.com'))
      expect {subject.call(:contact, :find_contacts, {})}.to raise_error Connectwise::UnknownHostError
    end

    it 'raises an UnknownCompanyError' do
      subject = Connectwise::Connection.new(credentials.merge(company_name: 'badcompanyname'))
      expect {subject.call(:contact, :find_contacts, {})}.to raise_error Connectwise::UnknownCompanyError
    end

    it 'raises a BadCredentialsError' do
      subject = Connectwise::Connection.new(credentials.merge(integrator_login_id: 'badloginname'))
      expect {subject.call(:contact, :find_contacts, {})}.to raise_error Connectwise::BadCredentialsError
    end

    it 'raises a ConnectionError' do
      expect {subject.call(:contact, :delete_contact, {})}.to raise_error Connectwise::ConnectionError
    end
  end
end
