require 'spec_helper'

describe Connectwise::Company do
  let(:credentials) { connectwise_credentials }
  let(:conn) { Connectwise::Connection.new(credentials) }
  let(:company) { OpenStruct.new name: 'Blue Sun'}
  subject {Connectwise::Company.new(conn, company.to_h)}

  it 'creates a company' do
    new_company = subject.save
    expect(new_company.persisted?).to eq true
    expect(new_company.id).not_to be_empty
    expect(new_company.status).to eq 'Active'
  end

  it 'fails to create a company' do
    subject.company_id = nil
    expect {subject.save}.to raise_error Connectwise::ConnectionError
  end

  it 'deletes a company' do
    new_company = subject.save
    instance = new_company.destroy
    expect {Connectwise::Company.find(conn, new_company.id) }.to raise_error Connectwise::RecordNotFound
    expect(instance).to eq new_company
  end

  it 'finds a company with search' do
    subject.save
    resp = Connectwise::Company.where(conn, company_name: 'Blue Sun')
    expect(resp).not_to be_empty
  end

  it 'finds a company with id', focus:true do
    new_company = subject.save
    resp = Connectwise::Company.find(conn, new_company.id)
    expect(resp).not_to be_nil
    expect(resp.id).to eq new_company.id
  end

  it 'finds no company with in id' do
    expect {Connectwise::Company.find(conn, 234234)}.to raise_error Connectwise::RecordNotFound
  end
end
