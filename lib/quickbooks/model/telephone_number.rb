module Quickbooks
  module Model
    class TelephoneNumber < BaseModel
      xml_accessor :free_form_number, from: 'FreeFormNumber'

      def initialize(number = nil)
        self.free_form_number = number unless number.nil?
      end
    end
  end
end
