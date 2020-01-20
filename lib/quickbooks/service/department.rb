module Quickbooks
  module Service
    class Department < BaseService
      def update(entity, options = {})
        if options[:sparse] && options[:sparse] == true
          raise Quickbooks::InvalidModelException, 'Department sparse update is not supported by Intuit at this time'
        end

        super(entity, options)
      end

      def delete(department)
        department.active = false
        update(department, sparse: false)
      end

      private

        def model
          Quickbooks::Model::Department
        end
    end
  end
end
