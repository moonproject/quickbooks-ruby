module Quickbooks
  module Service
    class BaseService
      include Quickbooks::Util::Logging
      include ServiceCrud

      attr_accessor :company_id
      attr_accessor :oauth
      attr_reader :base_uri
      attr_reader :last_response_xml
      attr_reader :last_response_intuit_tid

      XML_NS = %{xmlns="http://schema.intuit.com/finance/v3"}.freeze
      HTTP_CONTENT_TYPE = 'application/xml'.freeze
      HTTP_ACCEPT = 'application/xml'.freeze
      HTTP_ACCEPT_ENCODING = 'gzip, deflate'.freeze
      BASE_DOMAIN = 'quickbooks.api.intuit.com'.freeze
      SANDBOX_DOMAIN = 'sandbox-quickbooks.api.intuit.com'.freeze

      def initialize(attributes = {})
        domain = Quickbooks.sandbox_mode ? SANDBOX_DOMAIN : BASE_DOMAIN
        @base_uri = "https://#{domain}/v3/company"
        attributes.each { |key, value| public_send("#{key}=", value) }
      end

      def access_token=(token)
        @oauth = token
        rebuild_connection!
      end

      attr_writer :company_id

      # realm & company are synonymous
      def realm_id=(company_id)
        @company_id = company_id
      end

      # def oauth_v2?
      #   @oauth.is_a? OAuth2::AccessToken
      # end

      # [OAuth2] The default Faraday connection does not have gzip or multipart support.
      # We need to reset the existing connection and build a new one.
      def rebuild_connection!
        @oauth.client.connection = nil
        @oauth.client.connection.build do |builder|
          builder.use :gzip
          builder.request :multipart
          builder.request :url_encoded
          builder.adapter :net_http
        end
      end

      def url_for_resource(resource)
        "#{url_for_base}/#{resource}"
      end

      def url_for_base
        raise MissingRealmError unless @company_id

        "#{@base_uri}/#{@company_id}"
      end

      def is_json?
        self.class::HTTP_CONTENT_TYPE == 'application/json'
      end

      def is_pdf?
        self.class::HTTP_CONTENT_TYPE == 'application/pdf'
      end

      def default_model_query
        "SELECT * FROM #{self.class.name.split('::').last}"
      end

      def url_for_query(query = nil, start_position = 1, max_results = 20, _options = {})
        query ||= default_model_query
        query = "#{query} STARTPOSITION #{start_position} MAXRESULTS #{max_results}"

        "#{url_for_base}/query?query=#{CGI.escape(query)}"
      end

      private

        def parse_xml(xml)
          @last_response_xml = Nokogiri::XML(xml)
        end

        def valid_xml_document(xml)
          %{<?xml version="1.0" encoding="utf-8"?>\n#{xml.strip}}
        end

        # A single object response is the same as a collection response except
        # it just has a single main element
        def fetch_object(model, url, params = {})
          raise ArgumentError, 'missing model to instantiate' if model.nil?

          response = do_http_get(url, params)
          collection = parse_collection(response, model)
          collection.entries.first if collection.is_a?(Quickbooks::Collection)
        end

        def fetch_collection(query, model, options = {})
          page = options.fetch(:page, 1)
          per_page = options.fetch(:per_page, 20)

          start_position = ((page - 1) * per_page) + 1 # page=2, per_page=10 then we want to start at 11
          max_results = per_page

          response = do_http_get(url_for_query(query, start_position, max_results))

          parse_collection(response, model)
        end

        def parse_collection(response, model)
          if response
            collection = Quickbooks::Collection.new
            xml = @last_response_xml
            begin
              results = []

              query_response = xml.xpath('//xmlns:IntuitResponse/xmlns:QueryResponse')[0]
              if query_response

                start_pos_attr = query_response.attributes['startPosition']
                collection.start_position = start_pos_attr.value.to_i if start_pos_attr

                max_results_attr = query_response.attributes['maxResults']
                collection.max_results = max_results_attr.value.to_i if max_results_attr

                total_count_attr = query_response.attributes['totalCount']
                collection.total_count = total_count_attr.value.to_i if total_count_attr
              end

              path_to_nodes = "//xmlns:IntuitResponse//xmlns:#{model::XML_NODE}"
              collection.count = xml.xpath(path_to_nodes).count
              if collection.count > 0
                xml.xpath(path_to_nodes).each do |xa|
                  results << model.from_xml(xa)
                end
              end

              collection.entries = results
            rescue StandardError => ex
              raise Quickbooks::IntuitRequestException, "Error parsing XML: #{ex.message}"
            end
            collection
          end
        end

        # Given an IntuitResponse which is expected to wrap a single
        # Entity node, e.g.
        # <IntuitResponse xmlns="http://schema.intuit.com/finance/v3" time="2013-11-16T10:26:42.762-08:00">
        #   <Customer domain="QBO" sparse="false">
        #     <Id>1</Id>
        #     ...
        #   </Customer>
        # </IntuitResponse>
        def parse_singular_entity_response(model, xml, node_xpath_prefix = nil)
          xmldoc = Nokogiri(xml)
          prefix = node_xpath_prefix || model::XML_NODE
          xmldoc.xpath("//xmlns:IntuitResponse/xmlns:#{prefix}")[0]
        end

        # A successful delete request returns a XML packet like:
        # <IntuitResponse xmlns="http://schema.intuit.com/finance/v3" time="2013-04-23T08:30:33.626-07:00">
        #   <Payment domain="QBO" status="Deleted">
        #   <Id>8748</Id>
        #   </Payment>
        # </IntuitResponse>
        def parse_singular_entity_response_for_delete(model, xml)
          xmldoc = Nokogiri(xml)
          xmldoc.xpath("//xmlns:IntuitResponse/xmlns:#{model::XML_NODE}[@status='Deleted']").length == 1
        end

        def do_http_post(url, body = '', params = {}, headers = {}) # throws IntuitRequestException
          url = add_query_string_to_url(url, params)
          do_http(:post, url, body, headers)
        end

        def do_http_get(url, params = {}, headers = {}) # throws IntuitRequestException
          url = add_query_string_to_url(url, params)
          do_http(:get, url, {}, headers)
        end

        def do_http_raw_get(url, params = {}, headers = {})
          url = add_query_string_to_url(url, params)
          headers['Content-Type'] = self.class::HTTP_CONTENT_TYPE unless headers.key?('Content-Type')
          headers['Accept'] = self.class::HTTP_ACCEPT unless headers.key?('Accept')
          headers['Accept-Encoding'] = HTTP_ACCEPT_ENCODING unless headers.key?('Accept-Encoding')
          raw_response = oauth_get(url, headers)
          Quickbooks::Service::Responses::OAuthHttpResponse.wrap(raw_response)
        end

        def do_http_file_upload(uploadIO, url, metadata = nil)
          headers = {
            'Content-Type' => 'multipart/form-data'
          }
          body = {}
          body['file_content_0'] = uploadIO

          if metadata
            standalone_prefix = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            meta_data_xml = "#{standalone_prefix}\n#{metadata.to_xml_ns}"
            param_part = UploadIO.new(StringIO.new(meta_data_xml), 'application/xml')
            body['file_metadata_0'] = param_part
          end

          do_http(:upload, url, body, headers)
        end

        def do_http(method, url, body, headers) # throws IntuitRequestException
          raise 'OAuth client has not been initialized. Initialize with setter access_token=' if @oauth.nil?

          headers['Content-Type'] = self.class::HTTP_CONTENT_TYPE unless headers.key?('Content-Type')
          headers['Accept'] = self.class::HTTP_ACCEPT unless headers.key?('Accept')
          headers['Accept-Encoding'] = HTTP_ACCEPT_ENCODING unless headers.key?('Accept-Encoding')

          log '------ QUICKBOOKS-RUBY REQUEST ------'
          log "METHOD = #{method}"
          log "RESOURCE = #{url}"
          log_request_body(body)
          log "REQUEST HEADERS = #{headers.inspect}"

          raw_response = case method
                         when :get
                           oauth_get(url, headers)
                         when :post
                           oauth_post(url, body, headers)
                         when :upload
                           oauth_post_with_multipart(url, body, headers)
                         else
                           raise 'Do not know how to perform that HTTP operation'
          end

          response = Quickbooks::Service::Responses::OAuthHttpResponse.wrap(raw_response)
          log '------ QUICKBOOKS-RUBY RESPONSE ------'
          log "RESPONSE CODE = #{response.code}"
          log_response_body(response)
          log "RESPONSE HEADERS = #{response.headers}" if response.respond_to?(:headers)
          check_response(response, request: body)
        end

        def oauth_get(url, headers)
          @oauth.get(url, headers: headers, raise_errors: false)
        end

        def oauth_post(url, body, headers)
          @oauth.post(url, headers: headers, body: body, raise_errors: false)
        end

        def oauth_post_with_multipart(url, body, headers)
          @oauth.post_with_multipart(url, headers: headers, body: body, raise_errors: false)
        end

        def add_query_string_to_url(url, params)
          if params.is_a?(Hash) && !params.empty?
            keyvalues = params.collect { |k| "#{k.first}=#{k.last}" }.join('&')
            delim = !url.index('?').nil? ? '&' : '?'
            url + delim + keyvalues
          else
            url
          end
        end

        def check_response(response, options = {})
          if is_json?
            parse_json(response.plain_body)
          elsif !is_pdf?
            parse_xml(response.plain_body)
          end

          @last_response_intuit_tid = (response.headers['intuit_tid'] if response.respond_to?(:headers) && response.headers)

          status = response.code.to_i
          case status
          when 200
            # even HTTP 200 can contain an error, so we always have to peek for an Error
            if response_is_error?
              parse_and_raise_exception(options)
            else
              response
            end
          when 302
            raise 'Unhandled HTTP Redirect'
          when 401
            raise Quickbooks::AuthorizationFailure, parse_intuit_error
          when 403
            message = parse_intuit_error[:message]
            raise Quickbooks::ThrottleExceeded, message if message.include?('ThrottleExceeded')

            raise Quickbooks::Forbidden, message
          when 404
            raise Quickbooks::NotFound
          when 413
            raise Quickbooks::RequestTooLarge
          when 400, 500
            parse_and_raise_exception(options)
          when 429
            message = parse_intuit_error[:message]
            raise Quickbooks::TooManyRequests, message
          when 502, 503, 504
            raise Quickbooks::ServiceUnavailable
          else
            raise "HTTP Error Code: #{status}, Msg: #{response.plain_body}"
          end
        end

        def log_response_body(response)
          log 'RESPONSE BODY:'
          if is_json?
            log ">>>>#{response.plain_body.inspect}"
          elsif is_pdf?
            log('BODY is a PDF : not dumping')
          else
            log(log_xml(response.plain_body))
          end
        end

        def log_request_body(body)
          log 'REQUEST BODY:'
          if is_json?
            log(body.inspect)
          elsif is_pdf?
            log('BODY is a PDF : not dumping')
          else
            # multipart request for uploads arrive here in a Hash with UploadIO vals
            if body.is_a?(Hash)
              body.each do |k, v|
                log('BODY PART:')
                val_content = v.inspect
                if v.is_a?(UploadIO)
                  if v.content_type == 'application/xml'
                    val_content = log_xml(v.io.string) if v.io.is_a?(StringIO)
                  end
                end
                log("#{k}: #{val_content}")
              end
            else
              log(log_xml(body))
            end
          end
        end

        def parse_and_raise_exception(options = {})
          err = parse_intuit_error
          ex = Quickbooks::IntuitRequestException.new("#{err[:message]}:\n\t#{err[:detail]}")
          ex.code = err[:code]
          ex.detail = err[:detail]
          ex.type = err[:type]
          if is_json?
            ex.request_json = options[:request]
          else
            ex.request_xml = options[:request]
          end
          ex.intuit_tid = err[:intuit_tid]
          raise ex
        end

        def response_is_error?
          !@last_response_xml.xpath('//xmlns:IntuitResponse/xmlns:Fault')[0].nil?
        rescue Nokogiri::XML::XPath::SyntaxError => exception
          # puts @last_response_xml.to_xml.to_s
          # puts "WTF: #{exception.inspect}:#{exception.backtrace.join("\n")}"
          true
        end

        def parse_intuit_error
          error = { message: '', detail: '', type: nil, code: 0, intuit_tid: @last_response_intuit_tid }
          fault = @last_response_xml.xpath('//xmlns:IntuitResponse/xmlns:Fault')[0]
          if fault
            error[:type] = fault.attributes['type'].value

            error_element = fault.xpath('//xmlns:Error')[0]
            if error_element
              code_attr = error_element.attributes['code']
              error[:code] = code_attr.value if code_attr
              element_attr = error_element.attributes['element']
              error[:element] = code_attr.value if element_attr
              error[:message] = error_element.xpath('//xmlns:Message').text
              error[:detail] = error_element.xpath('//xmlns:Detail').text
            end
          end

          error
        rescue Nokogiri::XML::XPath::SyntaxError => exception
          error[:detail] = @last_response_xml.to_s

          error
        end
    end
  end
end
