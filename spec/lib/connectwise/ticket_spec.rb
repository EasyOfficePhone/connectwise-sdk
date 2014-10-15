require 'spec_helper'

describe Connectwise::Ticket do
  let(:credentials) { connectwise_credentials }
  let(:conn) { Connectwise::Connection.new(credentials) }
  let(:company_attrs) { {name: 'Pandorica'} }
  let(:ticket_attrs) { {summary: 'Help me', problem_description: 'I need the doctor!'} }
  let(:company) { Connectwise::Company.new(conn, company_attrs) }
  subject {Connectwise::Ticket.new(conn, ticket_attrs)}

  it 'creates a ticket' do
    conn.log = true
    subject.company = company.save
    new_ticket = subject.save
    expect(new_ticket.persisted?).to eq true
    expect(new_ticket.ticket_number).not_to be_empty
  end

  it 'finds a service ticket' do
    subject.company = company
    new_ticket = subject.save
    resp = Connectwise::Ticket.where(conn, subject: 'Help me')
    expect(resp).not_to be_empty
  end
end
