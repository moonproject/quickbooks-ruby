module Quickbooks
  module Model
    class BaseModelJSON < BaseModel
      def to_json(*_args)
        params = {}
        attributes.each_pair do |k, v|
          next if v.blank?

          params[k.camelize] = v.is_a?(Array) ? v.each_with_object([]) { |item, mem| mem << item.to_json; } : v
        end
        params.to_json
      end
    end
  end
end
