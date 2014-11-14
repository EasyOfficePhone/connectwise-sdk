require 'spec_helper'

describe Connectwise::Ticket do
  let(:credentials) { connectwise_credentials }
  let(:conn) { Connectwise::Connection.new(credentials) }
  let(:company_attrs) { {name: 'Pandorica'} }
  let(:ticket_attrs) { {summary: 'Help me', problem_description: 'I need the doctor!'} }
  let(:company) { Connectwise::Company.new(conn, company_attrs) }
  subject {Connectwise::Ticket.new(conn, ticket_attrs)}

  it 'creates a ticket' do
    orig_company = company.save
    subject.company = orig_company
    new_ticket = subject.save
    expect(new_ticket.persisted?).to eq true
    expect(new_ticket.company_id).to eq orig_company.company_id
    expect(new_ticket.closed_flag).to eq false
    #expect(new_ticket.member_id).to eq ''
  end

  it 'finds a service ticket' do
    subject.company = company.save
    new_ticket = subject.save
    resp = Connectwise::Ticket.where(conn, summary: 'Help me')
    expect(resp).not_to be_empty
    expect(resp.first.persisted?).to eq true
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
    deleted_ticket = found_ticket.destroy
    expect(deleted_ticket).not_to be_nil
    expect {Connectwise::Ticket.find(conn, new_ticket.id)}.to raise_error Connectwise::RecordNotFound
  end

  it 'adds a note to the ticket' do
    subject.company = company.save
    new_ticket = subject.save
    ticket_note = new_ticket.add_note('Message of some kind')
    expect(ticket_note.persisted?).to eq true
    expect(ticket_note.external?).to eq true
  end

  it 'adds an internal note to the ticket' do
    subject.company = company.save
    new_ticket = subject.save
    ticket_note = new_ticket.add_note('Message of some kind', type: :internal)
    expect(ticket_note.persisted?).to eq true
    expect(ticket_note.internal?).to eq true
  end

  it 'parses a post callback' do
    entity = {'Summary' => 'A summary', 'ClosedFlag' => false, 'Severity' => 'High', 'CompanyId' => 'acompany Id', 'memberId' => 'Admin1'}
    cw_params = {'Other data' => 'not sure what', 'Entity' => entity.to_json}
    params = {
      cw_params.to_json => nil,
      id: 12
    }
    ticket = Connectwise::Ticket.parse(conn, params)
    expect(ticket.summary).to eq entity['Summary']
    expect(ticket.closed_flag).to eq entity['ClosedFlag']
    expect(ticket.severity).to eq entity['Severity']
    expect(ticket.company_id).to eq entity['CompanyId']
    expect(ticket.member_id).to eq entity['memberId']
  end

  it 'allows access to the notes contained within it' do
    subject.company = company.save
    new_ticket = subject.save
    new_ticket.add_note('this api sucks')
    resp = Connectwise::Ticket.find(conn, new_ticket.id)
    expect(resp.notes).to be_kind_of(Array)
  end

  it 'allows access to the note contained within it' do
    subject.company = company.save
    new_ticket = subject.save
    resp = Connectwise::Ticket.find(conn, new_ticket.id)
    expect(resp.notes).to be_kind_of(Array)
  end
end
