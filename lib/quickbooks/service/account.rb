module Quickbooks
  module Service
    class Account < BaseService

      def delete(account)
        account.active = false
        update(account, sparse: true)
      end

      # def url_for_resource(resource)
      #   url = super(resource)
      #   "#{url}?minorversion=#{Quickbooks::Model::Account::MINORVERSION}"
      # end

      # def fetch_by_id(id, params = {})
      #   url = "#{url_for_base}/account/#{id}?minorversion=#{Quickbooks::Model::Account::MINORVERSION}"
      #   fetch_object(model, url, params)
      # end

      # def url_for_query(query = nil, start_position = 1, max_results = 20, options = {})
      #   url = super(query, start_position, max_results, options)
      #   "#{url}&minorversion=#{Quickbooks::Model::Account::MINORVERSION}"
      # end

      # def url_for_query(query = nil, start_position = 1, max_results = 20, options = {})
      #   url = super(query, start_position, max_results, options)
      #   "#{url}&minorversion=#{Quickbooks::Model::Account::MINORVERSION}"
      # end

      private

      def model
        Quickbooks::Model::Account
      end
    end
  end
end
