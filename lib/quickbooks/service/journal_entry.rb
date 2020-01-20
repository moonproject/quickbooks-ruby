module Quickbooks
  module Service
    class JournalEntry < BaseService
      def delete(entry)
        delete_by_query_string(entry)
      end

      def url_for_resource(resource)
        url = super(resource)
        "#{url}?minorversion=#{Quickbooks::Model::JournalEntry::MINORVERSION}"
      end

      def fetch_by_id(id, params = {})
        url = "#{url_for_base}/item/#{id}?minorversion=#{Quickbooks::Model::JournalEntry::MINORVERSION}"
        fetch_object(model, url, params)
      end

      def url_for_query(query = nil, start_position = 1, max_results = 20, options = {})
        url = super(query, start_position, max_results, options)
        "#{url}&minorversion=#{Quickbooks::Model::JournalEntry::MINORVERSION}"
      end

      private

        def model
          Quickbooks::Model::JournalEntry
        end
    end
  end
end
