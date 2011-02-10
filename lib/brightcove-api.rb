require 'httparty'
require 'json'
require 'rest-client'

module Brightcove
  class API
    include HTTParty
    
    VERSION = '1.0.6'.freeze
    
    DEFAULT_HEADERS = {
      'User-Agent' => "brightcove-api gem #{VERSION}"
    }
    
    headers(DEFAULT_HEADERS)
        
    READ_API_URL = 'http://api.brightcove.com/services/library'
    WRITE_API_URL = 'http://api.brightcove.com/services/post'
    
    attr_accessor :read_api_url
    attr_accessor :write_api_url
    attr_accessor :token
        
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
    
    # Call Brightcove using a particular API method, api_method. The options hash is where you can add any parameters appropriate for the API call.
    def get(api_method, options = {})
      options.merge!({:command => api_method})
      options.merge!({:token => @token})

      query = {}
      query.merge!({:query => options})
            
      self.class.get(@read_api_url, query)
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
          
      response = RestClient.post(@write_api_url, {
        :json => body.to_json,
        :file => File.new(file, 'rb')
      }, :content_type => :json, :accept => :json, :multipart => true)
      
      JSON.parse(response)
    end
  end
end