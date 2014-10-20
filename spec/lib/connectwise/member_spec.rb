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

  it 'finds multiple members using string syntax' do
    response = subject.where(conn, "MemberID='admin1' or MemberID='admin2'")
    expect(response.count).to eq 2
    expect(response.first.class).to eq Connectwise::Member
  end

  it 'finds a single member using string syntax' do
    response = subject.where(conn, "MemberID='admin1'")
    expect(response.count).to eq 1
    expect(response.first.class).to eq Connectwise::Member
  end
end
