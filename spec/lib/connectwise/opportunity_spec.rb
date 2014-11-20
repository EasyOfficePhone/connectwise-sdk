require 'spec_helper'

describe Connectwise::Opportunity do
  let(:credentials) { connectwise_credentials }
  let(:conn) { Connectwise::Connection.new(credentials) }
  let(:company_attrs) { {name: 'Blue Sun'} }
  let(:contact_attrs) { {first_name: 'Malcom', last_name: 'Reynolds'} }
  let(:opp_attrs) { {name: 'Something', source: 'EOP', primary_sales_rep: 'Admin1'} }
  let(:full_op) {
    @new_company = Connectwise::Company.new(conn, company_attrs).save
    @new_contact = Connectwise::Contact.new(conn, contact_attrs.merge(company: @new_company)).save
    Connectwise::Opportunity.new(conn, opp_attrs.merge(company: @new_company, contact: @new_contact)).save
  }
  subject {Connectwise::Opportunity}

  it 'creates an opportunity' do
    new_company = Connectwise::Company.new(conn, company_attrs).save
    new_contact = Connectwise::Contact.new(conn, contact_attrs.merge(company: new_company)).save
    resp = subject.new(conn, opp_attrs.merge(company: new_company, contact: new_contact)).save
    expect(resp.persisted?).to eq true
  end

  it 'finds opportunities' do
    new_opp = full_op
    found_opps = Connectwise::Opportunity.where(conn, opp_attrs.delete_if {|k, v| k == :source})
    expect(found_opps).not_to be_empty
  end

  it 'finds no opportunities' do
    found_opps = Connectwise::Opportunity.where(conn, name: 'Non-existent name')
    expect(found_opps).to be_empty
  end

  it 'gets an opportunity' do
    new_opp = full_op
    found_opp = Connectwise::Opportunity.find(conn, new_opp.id)
    expect(found_opp.id).not_to be_nil
    expect(found_opp.company_id).to eq @new_company.company_id
    expect(found_opp.contact_id).to eq @new_contact.id
  end

  it 'can change and resave a found opportunity' do
    new_opp = full_op
    found_opp = Connectwise::Opportunity.find(conn, new_opp.id)
    found_opp.primary_sales_rep = 'Admin2'
    expect {found_opp.save}.not_to raise_error
  end

  it 'fails to find an opportunity' do
    expect { Connectwise::Opportunity.find(conn, 123123123) }.to raise_error Connectwise::RecordNotFound
  end

  it 'deletes an opportunity' do
    new_opp = full_op
    new_opp.destroy
    expect {Connectwise::Opportunity.find(conn, new_opp.id)}.to raise_error Connectwise::RecordNotFound
  end
end
