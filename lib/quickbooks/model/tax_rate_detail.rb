module Quickbooks
  module Model
    class TaxRateDetail < BaseModel
      XML_COLLECTION_NODE = 'TaxRateDetail'.freeze
      XML_NODE = 'TaxRateDetail'.freeze
      REST_RESOURCE = 'taxratedetail'.freeze

      xml_accessor :tax_rate_ref, from: 'TaxRateRef', as: BaseReference
      xml_accessor :tax_type_applicable, from: 'TaxTypeApplicable'
      xml_accessor :tax_order, from: 'TaxOrder'

      reference_setters :tax_rate_ref
    end
  end
end
