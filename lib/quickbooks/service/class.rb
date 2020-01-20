module Quickbooks
  module Service
    class Class < BaseService
      def update(entity, options = {})
        if options[:sparse] && options[:sparse] == true
          raise Quickbooks::InvalidModelException, 'Class sparse update is not supported by Intuit at this time'
        end

        super(entity, options)
      end

      def delete(classs)
        classs.active = false
        update(classs, sparse: false)
      end

      private

        def model
          Quickbooks::Model::Class
        end
    end
  end
end
