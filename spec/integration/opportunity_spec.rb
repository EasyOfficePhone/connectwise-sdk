require 'spec_helper'

describe 'Opportunity' do
  let(:credentials) { connectwise_credentials }
  let(:conn) { Connectwise::Connection.new(credentials) }
  let(:contact_attrs) { {first_name: 'Malcom', last_name: 'Reynolds'} }
  let(:company_attrs) { {name: 'Blue Sun'} }

  it 'creates a company and a contact and connects them' do
    new_company = Connectwise::Company.new(conn, name: 'Blue Sun').save
    new_contact = Connectwise::Contact.new(conn, contact_attrs)
    new_contact.company = new_company
    new_contact = new_contact.save
    resp = Connectwise::Contact.find(conn, new_contact.id)
    expect(resp.company_id).to eq new_company.company_id
  end
end
