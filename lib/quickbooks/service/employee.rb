module Quickbooks
  module Service
    class Employee < BaseService
      # override update as sparse is not supported
      def update(entity, options = {})
        if options[:sparse] && options[:sparse] == true
          raise Quickbooks::InvalidModelException, 'Employee sparse update is not supported by Intuit at this time'
        end

        super(entity, options)
      end

      def delete(employee)
        employee.active = false
        update(employee, sparse: false)
      end

      private

        def model
          Quickbooks::Model::Employee
        end
    end
  end
end
