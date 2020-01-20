module Quickbooks
  module Model
    class SalesTaxRateList < BaseModel
      XML_COLLECTION_NODE = 'SalesTaxRateList'.freeze
      XML_NODE = 'SalesTaxRateList'.freeze
      REST_RESOURCE = 'salestaxratelist'.freeze

      xml_accessor :tax_rate_detail, from: 'TaxRateDetail', as: [TaxRateDetail]
    end
  end
end
