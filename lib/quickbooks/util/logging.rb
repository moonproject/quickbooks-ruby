module Quickbooks
  module Util
    module Logging
      def log(msg)
        ::Quickbooks.log(msg)
      end

      def log?
        ::Quickbooks.log?
      end

      def log_xml(str)
        if ::Quickbooks.log_xml_pretty_print? && !(str && str.empty?)
          Nokogiri::XML(str).to_xml
        else
          str
        end
      rescue StandardError => e
        e
      end
    end
  end
end
