module Connectwise
  class Member
    include Model
    attr_accessor :email_address, :first_name, :last_name, :id

    def self.where(connection, **attrs)
      resp = connection.call :member, :find_members, {conditions: attrs_to_query(attrs)}
      Array(resp[:member_find_result]).map {|attrs| cw_to_model(connection, attrs) }
    end

    private
    def self.cw_to_model(conn, attrs)
      id = attrs.delete(:member_id)
      self.new(conn, id: id, **attrs)
    end
  end
end
