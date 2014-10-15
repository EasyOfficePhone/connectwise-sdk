require 'spec_helper'

module Connectwise
  describe Contact do
    let(:credentials) { connectwise_credentials }
    let(:conn) { Connectwise::Connection.new(credentials) }
    let(:contact) { OpenStruct.new first_name: 'Malcom', last_name: 'Reynolds' }
    subject {Connectwise::Contact.new(conn, contact.to_h)}

    before :each do
      #conn.log = true
    end

    it 'creates a contact' do
      new_contact = subject.save
      expect(new_contact.persisted?).to eq true
      expect(new_contact.id).not_to be_empty
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

    it 'finds a contact with id' do
      new_contact = subject.save
      resp = Connectwise::Contact.find(conn, new_contact.id)
      expect(resp).not_to be_nil
      expect(resp.id).to eq new_contact.id
    end

    it 'finds no contact with in id' do
      expect {Connectwise::Contact.find(conn, 234234)}.to raise_error Connectwise::RecordNotFound
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
end
