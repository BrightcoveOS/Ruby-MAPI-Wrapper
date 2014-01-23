require 'httparty'
require 'json'
require 'rest-client'
require 'orderedhash'
require 'net/http/post/multipart'
require 'brightcove-api/version'

module Brightcove
  class API
    include HTTParty
    disable_rails_query_string_format

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

    # Initialize a new instance of the +Brightcove::API+ using a Brightcove token.
    #
    # @param token [String] Brightcove token which can be a read-only, write or read-write token.
    # @param read_api_url [String] Read API URL or the default of +Brightcove::API::READ_API_URL+.
    # @param write_api_url [String] Write API URL or the default of +Brightcove::API::WRITE_API_URL+.
    def initialize(token, read_api_url = READ_API_URL, write_api_url = WRITE_API_URL)
      @token = token
      @read_api_url = read_api_url
      @write_api_url = write_api_url
      @timeout = nil
      @open_timeout = nil
    end

    # Set a location for debug HTTP output to be written to.
    # 
    # @param location [Object] Defaults to +$stderr+.
    def debug(location = $stderr)
      self.class.debug_output(location)
    end

    # Set HTTP headers that should be used in API requests. The 
    # +Brightcove::API::DEFAULT_HEADERS+ will be merged into the passed-in
    # hash.
    #
    # @param http_headers [Hash] Updated HTTP headers.
    def set_http_headers(http_headers = {})
      http_headers.merge!(DEFAULT_HEADERS)
      headers(http_headers)
    end

    # Set a timeout for HTTP requests.
    # 
    # @param timeout [int] HTTP timeout value.
    def set_timeout(timeout)
      default_timeout(timeout)
    end

    # Make an HTTP GET call to the Brightcove API for a particular API method.
    #
    # @param api_method [String] Brightcove API method.
    # @param options [Hash] Optional hash containing parameter names and values. The options 
    #   parameter can be either a query string or a hash. If a query string, it will be
    #   normalized to a hash via CGI.parse.
    def get(api_method, options = {})
      self.class.get(@read_api_url, build_query_from_options(api_method, options))
    end

    # Make an HTTP POST call to the Brightcove API for a particular API method.
    # 
    # @param api_method [String] Brightcove API method.
    # @param parameters [Hash] Optional hash containing parameter names and values.
    def post(api_method, parameters = {})
      parameters.merge!({"token" => @token})

      body = {}
      body.merge!({:method => api_method})
      body.merge!({:params => parameters})

      self.class.post(@write_api_url, {:body => {:json => JSON.generate(body)}})
    end

    # Post a file to the Brightcove API, e.g. uploading video. 
    #
    # @param api_method [String] Brightcove API method.
    # @param file [String] Full path of file to be uploaded.
    # @param parameters [Hash] Optional hash containing parameter names and values.
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
    
    # Post a file via HTTP streaming to the Brightcove API, e.g. uploading video. 
    #
    # @param api_method [String] Brightcove API method.
    # @param upload_file [String] Full path of file to be uploaded.
    # @param parameters [Hash] Optional hash containing parameter names and values.
    def post_file_streaming(api_method, upload_file, content_type, parameters)
      File.open(upload_file) { |file| post_io_streaming(api_method, file, content_type, parameters) }
    end
    
    # Post a file IO object via HTTP streaming to the Brightcove API, e.g. uploading video. 
    #
    # @param api_method [String] Brightcove API method.
    # @param file [File handle] File handle of file to be uploaded.
    # @param parameters [Hash] Optional hash containing parameter names and values.
    def post_io_streaming(api_method, file, content_type, parameters)
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
      
      payload[:json] = body.to_json

      if file.is_a?(UploadIO)
        payload[:file] = file
      else
        filename = file.respond_to?(:base_uri) ? File.basename(file.base_uri.to_s) : File.basename(file.path) rescue nil
        payload[:file] = UploadIO.new(file, content_type, filename)
      end
      
      request = Net::HTTP::Post::Multipart.new(url.path, payload)
      
      response = Net::HTTP.start(url.host, url.port) do |http|
        http.read_timeout = @timeout if @timeout
        http.open_timeout = @open_timeout if @open_timeout
        http.request(request)
      end

      JSON.parse(response.body)
    end

    private

    # Build an appropriate query for the Brightcove API given an +api_method+ and +options+.
    # This will also merge in your API token and set the +format+ to XML if +mrss+ has been 
    # requested for the +:output+.
    #
    # @param api_method [String] Brightcove API method.
    # @param options [Hash] Optional hash containing parameter names and values.
    def build_query_from_options(api_method, options = {})
      # normalize options to a hash
      unless options.respond_to?(:merge!)
        options = CGI.parse(options)
      end
      
      options.merge!({:command => api_method, :token => @token})
      options.merge!({:format => :xml}) if options.key?(:output) && 'mrss'.eql?(options[:output])
      { :query => options }
    end    
  end
end
