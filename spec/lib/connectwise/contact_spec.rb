require 'spec_helper'

describe Connectwise::Contact do
  let(:credentials) { connectwise_credentials }
  let(:conn) { Connectwise::Connection.new(credentials) }
  let(:contact) { OpenStruct.new first_name: 'Malcom', last_name: 'Reynolds' }
  subject {Connectwise::Contact.new(conn, contact.to_h)}

  it 'creates a contact' do
    contact_id = contact.id
    new_contact = subject.save
    expect(new_contact.persisted?).to be_true
    expect(new_contact.id).not_to be_empty
    expect(contact_id).not_to eq new_contact.id
  end

  it 'finds a contact' do
    new_contact = subject.save
    new_contact = contact
    found_contacts = Connectwise::Contact.where(conn, first_name: new_contact.first_name, last_name: new_contact.last_name)
    expect(found_contacts).not_to be_empty
  end

  it 'finds no contact' do
    new_contact = subject.save
    found_contacts = Connectwise::Contact.where(conn, first_name: 'gobledy', last_name: 'gook')
    expect(found_contacts).to be_empty
  end

  it 'deletes a contact' do
    new_contact = subject.save
    found_contacts = Connectwise::Contact.where(conn, first_name: new_contact.first_name, last_name: new_contact.last_name)
    current_count = found_contacts.count
    deleted_contact = found_contacts.first.destroy
    expect(deleted_contact).not_to be_nil
    found_contacts = Connectwise::Contact.where(conn, first_name: new_contact.first_name, last_name: new_contact.last_name)
    expect(current_count - found_contacts.count).to eq 1
  end
end
