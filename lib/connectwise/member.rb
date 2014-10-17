module Connectwise
  class Member
    include Model
    attr_accessor :email_address, :first_name, :last_name, :id

    def self.find_transform(attrs)
      attrs[:id] = attrs.delete(:member_id)
      attrs
    end
  end
end
