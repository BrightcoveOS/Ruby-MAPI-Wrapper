require 'httparty'
require 'json'
require 'rest-client'
require 'orderedhash'

module Brightcove
  class API
    include HTTParty
    disable_rails_query_string_format

    VERSION = '1.0.8'.freeze

    DEFAULT_HEADERS = {
      'User-Agent' => "brightcove-api gem #{VERSION}"
    }

    headers(DEFAULT_HEADERS)

    READ_API_URL = 'http://api.brightcove.com/services/library'
    WRITE_API_URL = 'http://api.brightcove.com/services/post'

    attr_accessor :read_api_url
    attr_accessor :write_api_url
    attr_accessor :token
    
    # RestClient POST timeout for reading conection
    attr_accessor :timeout
    # RestClient POST timeout for opening connection
    attr_accessor :open_timeout

    # Brightcove returns text/html as the Content-Type for a response even though the response is JSON.
    # So, let's just parse the response as JSON
    format(:json)

    # Initialize with your API token
    def initialize(token, read_api_url = READ_API_URL, write_api_url = WRITE_API_URL)
      @token = token
      @read_api_url = read_api_url
      @write_api_url = write_api_url
    end

    def debug(location = $stderr)
      self.class.debug_output(location)
    end

    def set_http_headers(http_headers = {})
      http_headers.merge!(DEFAULT_HEADERS)
      headers(http_headers)
    end

    def set_timeout(timeout)
      default_timeout(timeout)
    end

    def build_query_from_options(api_method, options = {})
      # normalize options to a hash
      unless options.respond_to?(:merge!)
        options = CGI.parse(options)
      end
      options.merge!({:command => api_method, :token => @token})
      { :query => options }
    end

    # Call Brightcove using a particular API method, api_method.
    # The options parameter can be either a query string or a hash. In either case, it is where
    # you can add any parameters appropriate for the API call. If a query string, it will be
    # normalized to a hash via CGI.parse.
    def get(api_method, options = {})
      self.class.get(@read_api_url, build_query_from_options(api_method, options))
    end

    # Post to Brightcove using a particular API method, api_method. The parameters hash is where you add all the required parameters appropriate for the API call.
    def post(api_method, parameters = {})
      parameters.merge!({"token" => @token})

      body = {}
      body.merge!({:method => api_method})
      body.merge!({:params => parameters})

      self.class.post(@write_api_url, {:body => {:json => JSON.generate(body)}})
    end

    def post_file(api_method, file, parameters = {})
      parameters.merge!({"token" => @token})

      body = {}
      body.merge!({:method => api_method})
      body.merge!({:params => parameters})

      # Brightcove requires that the JSON-RPC call absolutely
      # be the first part of a multi-part POST like create_video.
      if RUBY_VERSION >= '1.9'
        payload = {}
      else
        payload = OrderedHash.new
      end

      payload[:json] = body.to_json
      payload[:file] = File.new(file, 'rb')

      response = RestClient::Request.execute(
        :method => :post,
        :url => @write_api_url,
        :payload => payload,
        :content_type => :json,
        :accept => :json,
        :multipart => true,
        :timeout => @timeout,
        :open_timeout => @open_timeout
      )

      JSON.parse(response)
    end
  end
end