module Quickbooks
  module Service
    class Vendor < BaseService
      # override update as sparse is not supported
      def update(entity, options = {})
        if options[:sparse] && options[:sparse] == true
          raise InvalidModelException, 'Vendor sparse update is not supported by Intuit at this time'
        end

        super(entity, options)
      end

      def delete(vendor)
        vendor.active = false
        update(vendor, sparse: false)
      end

      private

        def model
          Quickbooks::Model::Vendor
        end
    end
  end
end
