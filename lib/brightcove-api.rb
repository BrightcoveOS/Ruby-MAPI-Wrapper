require 'httparty'
require 'json'
require 'rest-client'
require 'orderedhash'
require 'net/http/post/multipart'

module Brightcove
  class API
    include HTTParty
    disable_rails_query_string_format

    VERSION = '1.0.11'

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

    # Initialize with your API token
    def initialize(token, read_api_url = READ_API_URL, write_api_url = WRITE_API_URL)
      @token = token
      @read_api_url = read_api_url
      @write_api_url = write_api_url
      @timeout = nil
      @open_timeout = nil
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
      options.merge!({:format => :xml}) if options.key?(:output) && 'mrss'.eql?(options[:output])
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
      
      execution_payload = {
        :method => :post,
        :url => @write_api_url,
        :payload => payload,
        :content_type => :json,
        :accept => :json,
        :multipart => true        
      }
      
      execution_payload[:timeout] = @timeout if @timeout
      execution_payload[:open_timeout] = @open_timeout if @open_timeout

      response = RestClient::Request.execute(execution_payload)

      JSON.parse(response)
    end
    
    def post_file_streaming(api_method, upload_file, content_type, parameters)
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
            
      url = URI.parse(@write_api_url)
      response = nil
      File.open(upload_file) do |file|
        payload[:json] = body.to_json
        payload[:file] = UploadIO.new(file, content_type)
        
        request = Net::HTTP::Post::Multipart.new(url.path, payload)
        
        response = Net::HTTP.start(url.host, url.port) do |http|
          http.read_timeout = @timeout if @timeout
          http.open_timeout = @open_timeout if @open_timeout
          http.request(request)
        end
      end

      JSON.parse(response.body)
    end
  end
end