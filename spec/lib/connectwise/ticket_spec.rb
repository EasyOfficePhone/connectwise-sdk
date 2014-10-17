require 'spec_helper'

describe Connectwise::Ticket do
  let(:credentials) { connectwise_credentials }
  let(:conn) { Connectwise::Connection.new(credentials) }
  let(:company_attrs) { {name: 'Pandorica'} }
  let(:ticket_attrs) { {summary: 'Help me', problem_description: 'I need the doctor!'} }
  let(:company) { Connectwise::Company.new(conn, company_attrs) }
  subject {Connectwise::Ticket.new(conn, ticket_attrs)}

  it 'creates a ticket' do
    subject.company = company.save
    new_ticket = subject.save
    expect(new_ticket.persisted?).to eq true
  end

  it 'finds a service ticket' do
    subject.company = company.save
    new_ticket = subject.save
    resp = Connectwise::Ticket.where(conn, summary: 'Help me')
    expect(resp).not_to be_empty
  end

  it 'finds no ticket' do
    subject.company = company.save
    new_ticket = subject.save
    found_tickets = Connectwise::Ticket.where(conn, summary: 'gobledy-gook')
    expect(found_tickets).to be_empty
  end

  it 'finds a ticket with id' do
    subject.company = company.save
    new_ticket = subject.save
    p new_ticket.id
    resp = Connectwise::Ticket.find(conn, new_ticket.id)
    expect(resp).not_to be_nil
    expect(resp.id).to eq new_ticket.id
  end

  it 'finds no ticket with in id' do
    expect {Connectwise::Ticket.find(conn, 234234)}.to raise_error Connectwise::RecordNotFound
  end

  it 'deletes a ticket' do
    subject.company = company.save
    new_ticket = subject.save
    found_ticket = Connectwise::Ticket.find(conn, new_ticket.id)
    expect(found_ticket).not_to be_nil
    deleted_ticket = found_tickets.first.destroy
    expect(deleted_ticket).not_to be_nil
    found_ticket = Connectwise::ticket.find(conn, new_ticket.id)
    expect(found_ticket).to be_nil
  end
end
