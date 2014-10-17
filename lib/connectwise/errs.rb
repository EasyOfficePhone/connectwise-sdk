module Connectwise
  class ConnectionError < StandardError; end
  class UnknownHostError < ConnectionError; end
  class UnknownCompanyError < ConnectionError; end
  class BadCredentialsError < ConnectionError; end
  class RecordNotFound < StandardError; end
end
