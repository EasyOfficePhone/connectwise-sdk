require_relative '../lib/connectwise_sdk'
require 'ostruct'

def connectwise_credentials
  conf = YAML::load_file(File.join(__dir__, 'credentials.yml'))
  conf['connectwise_credentials'].each_with_object({}) {|(k,v), h| h[k.to_sym] = v}
end

RSpec.configure do |c|
  #c.filter_run_including :focus => true
end
