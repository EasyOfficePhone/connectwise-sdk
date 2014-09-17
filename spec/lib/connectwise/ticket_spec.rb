require 'spec_helper'

describe Connectwise::Ticket do
  it 'creates a ticket' do
    new_company = subject.create_company(company)
    resp = subject.create_ticket(OpenStruct.new(subject: 'help', description: 'abcd go boom'), OpenStruct.new(id: new_company[:company_id]))
    expect(resp[:ticket_number]).not_to be_nil
  end

  it 'finds a service ticket' do
    new_company = subject.create_company(company)
    new_ticket = subject.create_ticket(OpenStruct.new(subject: 'help', description: 'abcd go boom'), OpenStruct.new(id: new_company[:company_id]))
    resp = subject.find_ticket(OpenStruct.new(id: new_ticket[:ticket_number]), OpenStruct.new(name: 'Gobledygook ragnok ramastrodon'))
    expect(resp).not_to be_empty
  end
end
