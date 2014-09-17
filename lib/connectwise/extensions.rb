module Connectwise
  module Extensions
    module String
      def camelize
        string = self.sub(/^[a-z\d]*/) { $&.capitalize }
        string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
      end
    end
  end
end
