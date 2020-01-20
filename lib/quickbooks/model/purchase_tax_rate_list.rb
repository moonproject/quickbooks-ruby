module Quickbooks
  module Model
    class PurchaseTaxRateList < BaseModel
      XML_COLLECTION_NODE = 'PurchaseTaxRateList'.freeze
      XML_NODE = 'PurchaseTaxRateList'.freeze
      REST_RESOURCE = 'purchasetaxratelist'.freeze

      xml_accessor :tax_rate_detail, from: 'TaxRateDetail', as: [TaxRateDetail]
    end
  end
end
