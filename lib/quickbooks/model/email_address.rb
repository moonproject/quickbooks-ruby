module Quickbooks
  module Model
    class EmailAddress < BaseModel
      xml_accessor :address, from: 'Address'

      def to_xml(options = {})
        return '' if address.to_s.empty?

        super
      end

      def initialize(email_address = nil)
        self.address = email_address unless email_address.nil?
      end
    end
  end
end
