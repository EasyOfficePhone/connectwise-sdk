require 'spec_helper'

describe Connectwise::TicketNote do
  let(:credentials) { connectwise_credentials }
  let(:conn) { Connectwise::Connection.new(credentials) }
  let(:company_attrs) { {name: 'Pandorica'} }
  let(:ticket_attrs) { {summary: 'Help me', problem_description: 'I need the doctor!'} }
  let(:company) { Connectwise::Company.new(conn, company_attrs) }
  let(:ticket) {
    t = Connectwise::Ticket.new(conn, ticket_attrs)
    t.company = company.save
    t.save
  }
  let(:ticket_note_attrs) { {note: 'some text to describe the note', type: :internal} }
  subject { Connectwise::TicketNote.new(conn, ticket_note_attrs.merge({ticket: ticket})) }

  it 'creates a ticket note' do
    new_ticket_note = subject.save
    expect(new_ticket_note.persisted?).to eq true
  end
end
