require 'time'

module Quickbooks
  module Model
    class EffectiveTaxRate < BaseModel
      XML_COLLECTION_NODE = 'EffectiveTaxRate'.freeze
      XML_NODE = 'EffectiveTaxRate'.freeze
      REST_RESOURCE = 'effectivetaxrate'.freeze

      xml_accessor :rate_value, from: 'RateValue'
      xml_accessor :effective_date, from: 'EffectiveDate', as: Time
      xml_accessor :end_date, from: 'EndDate', as: Time
    end
  end
end
