module Quickbooks
  module Model
    class TaxService < BaseModelJSON
      REST_RESOURCE = 'taxservice/taxcode'.freeze

      xml_accessor :tax_code_id, from: 'TaxCodeId'
      xml_accessor :tax_code, from: 'TaxCode'
      xml_accessor :tax_rate_details, from: 'TaxRateDetails', as: [TaxRateDetailLine]

      validates :tax_code, presence: true, length: { maximum: 100 }

      validate :check_details_item

      def initialize(options = {})
        self.tax_rate_details = options['tax_rate_details'] || []
        super
      end

      def self.from_json(response)
        result = JSON.parse(response)
        if result.present?
          ts = Quickbooks::Model::TaxService.new
          ts.tax_code = result['TaxCode']
          ts.tax_code_id = result['TaxCodeId']
          result['TaxRateDetails'].each do |item|
            attrs = item.keys.each_with_object({}) { |k, mem| mem[k.underscore] = item[k]; }
            ts.tax_rate_details << Quickbooks::Model::TaxRateDetailLine.new(attrs)
          end
          ts
        end
      end

      def check_details_item
        if tax_rate_details.blank?
          errors.add(:tax_rate_details, 'must have at least one item')
        else
          tax_rate_details.each do |line|
            errors.add(:base, line.errors.full_messages.join(', ')) unless line.valid?
          end
          names = tax_rate_details.map(&:tax_rate_name).uniq
          errors.add(:tax_rate_name, 'Duplicate Tax Rate Name') if names.size < tax_rate_details.size
        end
      end
    end
  end
end
