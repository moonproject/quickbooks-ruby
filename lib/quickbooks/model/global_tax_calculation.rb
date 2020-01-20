module GlobalTaxCalculation
  extend ActiveSupport::Concern

  TAX_INCLUSIVE = 'TaxInclusive'.freeze
  TAX_EXCLUDED = 'TaxExcluded'.freeze
  NOT_APPLICABLE = 'NotApplicable'.freeze
  GLOBAL_TAX_CALCULATION = [TAX_INCLUSIVE, TAX_EXCLUDED, NOT_APPLICABLE].freeze

  included do
    xml_accessor :global_tax_calculation, from: 'GlobalTaxCalculation'
    validates_inclusion_of :global_tax_calculation, in: GLOBAL_TAX_CALCULATION, allow_blank: true
  end
end
