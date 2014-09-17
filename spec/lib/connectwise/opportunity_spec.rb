require 'spec_helper'

describe Connectwise::Opportunity do
  it 'creates an opportunity' do
    new_company = subject.create_company(company)
    new_contact = subject.create_contact(contact, new_company[:company_id])
    resp = subject.create_opportunity(lead, new_company[:company_id], new_contact[:id])
    expect(resp[:id]).not_to be_empty
  end

  it 'deletes an opportunity' do
    new_company = subject.create_company(company)
    new_contact = subject.create_contact(contact, new_company[:company_id])
    new_opp = subject.create_opportunity(lead, new_company[:company_id], new_contact[:id])
    expect(subject.delete_opportunity(OpenStruct.new(id: new_opp[:id]))).to be_nil
  end
end
