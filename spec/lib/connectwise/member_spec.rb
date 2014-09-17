require 'spec_helper'

describe Connectwise::Member do
  let(:credentials) { connectwise_credentials }
  let(:conn) { Connectwise::Connection.new(credentials) }
  subject {Connectwise::Member}

  # Note this test relies on the default connectwise test setup where 'test@test.com' is every member's email
  it 'finds a member' do
    response = subject.where(conn, email_address: 'test@test.com')
    expect(response.first.class).to eq Connectwise::Member
    expect(response.first.email_address).to eq 'test@test.com'
  end
end
