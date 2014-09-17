require 'spec_helper'

describe Connectwise::Company do
  it 'creates a company' do
    expect(subject.create_company(company)[:id]).not_to be_empty
  end

  it 'fails to create a company' do
    company.id = nil
    expect {subject.create_company(company)}.to raise_error Connectwise::ConnectionError
  end

  it 'fails to create company and throws error' do
    company.id = nil
    expect {subject.create_company(company) do |err|
      fail ArgumentError
    end}.to raise_error ArgumentError
  end

  it 'deletes a company' do
    new_company = subject.create_company(company)
    expect(subject.delete_company(OpenStruct.new(id: new_company[:id]))).to be_nil
  end

  it 'finds a company' do
    resp = subject.find_company(OpenStruct.new name: 'Blue Sun', id: '6417')
    expect(resp).not_to be_empty
  end

  it 'creates a company and a contact and connects them' do
    new_company = subject.create_company(company)
    resp = subject.create_contact(contact, new_company[:company_id])
    expect(resp[:company_id]).to eql new_company[:company_id]
  end
end
