require 'helper'
require 'fakeweb'
require 'mocha'

class TestBrightcoveApi < Test::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.allow_net_connect = true
  end

  def test_api_version
    assert_equal '1.0.7', Brightcove::API::VERSION
  end

  def test_can_set_read_api_url
    brightcove = Brightcove::API.new('apikeytoken')

    assert_equal Brightcove::API::READ_API_URL, brightcove.read_api_url

    brightcove.read_api_url = 'http://some.api.com'

    assert_equal 'http://some.api.com', brightcove.read_api_url
  end

  def test_can_set_write_api_url
    brightcove = Brightcove::API.new('apikeytoken')

    assert_equal Brightcove::API::WRITE_API_URL, brightcove.write_api_url

    brightcove.write_api_url = 'http://some.api.com'

    assert_equal 'http://some.api.com', brightcove.write_api_url
  end

  def test_can_set_token
    brightcove = Brightcove::API.new('apikeytoken')

    assert_equal 'apikeytoken', brightcove.token
  end

  def test_can_set_http_headers
    brightcove = Brightcove::API.new('apikeytoken')
    brightcove.expects(:headers).at_least_once

    brightcove.set_http_headers({'Accept' => 'application/json'})
  end

  def test_can_set_timeout
    brightcove = Brightcove::API.new('apikeytoken')
    brightcove.expects(:default_timeout).at_least_once

    brightcove.set_timeout(5)
  end

  def test_find_all_videos
    FakeWeb.register_uri(:get,
                         'http://api.brightcove.com/services/library?page_size=5&token=0Z2dtxTdJAxtbZ-d0U7Bhio2V1Rhr5Iafl5FFtDPY8E.&command=find_all_videos',
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'find_all_videos_response.json'),
                         :content_type => "application/json")

    brightcove = Brightcove::API.new('0Z2dtxTdJAxtbZ-d0U7Bhio2V1Rhr5Iafl5FFtDPY8E.')
    brightcove_response = brightcove.get('find_all_videos', {:page_size => 5})

    assert_equal 5, brightcove_response['items'].size
    assert_equal 0, brightcove_response['page_number']
  end

  def test_search_with_array_params
    brightcove = Brightcove::API.new('0Z2dtxTdJAxtbZ-d0U7Bhio2V1Rhr5Iafl5FFtDPY8E.')
    brightcove.class.expects(:get).with(anything, has_entry(:query => {
      :any => ['tag:foo', 'tag:bar'],
      :command => 'search_videos',
      :token => '0Z2dtxTdJAxtbZ-d0U7Bhio2V1Rhr5Iafl5FFtDPY8E.'
    }))
    brightcove_response = brightcove.get('search_videos', { :any => [ "tag:foo", "tag:bar" ] })
  end

  def test_search_with_string_params
    brightcove = Brightcove::API.new('0Z2dtxTdJAxtbZ-d0U7Bhio2V1Rhr5Iafl5FFtDPY8E.')
    brightcove.class.expects(:get).with(anything, has_entry(:query => {
      'any' => ['tag:bar', 'tag:foo'],
      :command => 'search_videos',
      :token => '0Z2dtxTdJAxtbZ-d0U7Bhio2V1Rhr5Iafl5FFtDPY8E.'
    }))
    brightcove_response = brightcove.get('search_videos', 'any=tag:bar&any=tag:foo' )
  end

  def test_more_complicated_query
    brightcove = Brightcove::API.new('0Z2dtxTdJAxtbZ-d0U7Bhio2V1Rhr5Iafl5FFtDPY8E.')
    brightcove.class.expects(:get).with(anything, has_entry(:query => {
      :any => ['tag:foo', 'tag:bar'],
      :all => "search_text:foo",
      :command => 'search_videos',
      :token => '0Z2dtxTdJAxtbZ-d0U7Bhio2V1Rhr5Iafl5FFtDPY8E.'
    }))
    brightcove_response = brightcove.get('search_videos', { :any => [ "tag:foo", "tag:bar" ], :all => "search_text:foo" })
  end

  def test_brightcove_example_query
    FakeWeb.register_uri(:get,
                         'http://api.brightcove.com/services/library?all=chicago&all=football&all=tag%3Afree&any=tag%3Acolor&any=tag%3Atechnicolor&command=search_videos&token=1234.',
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'find_all_videos_response.json'),
                         :content_type => "application/json")

    brightcove = Brightcove::API.new('1234.')
    # brightcove.class.expects(:get).with(anything, has_entry(:query => {
    #   :any => ['tag:color', 'tag:technicolor'],
    #   :all => ['football', 'chicago', 'tag:free'],
    #   :command => 'search_videos',
    #   :token => '1234.'
    # }))
    brightcove_response = brightcove.get('search_videos', {
      :any => [ "tag:color", "tag:technicolor" ],
      :all => ["football", "chicago", "tag:free"]
    })

    assert_equal 5, brightcove_response['items'].size
  end

  def test_delete_video
    FakeWeb.register_uri(:post,
                         'http://api.brightcove.com/services/post',
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'delete_video_response.json'),
                         :content_type => "application/json")

    brightcove = Brightcove::API.new('0Z2dtxTdJAxtbZ-d0U7Bhio2V1Rhr5Iafl5FFtDPY8E.')
    brightcove_response = brightcove.post('delete_video', {:video_id => '595153261337'})

    assert brightcove_response.has_key?('result')
    assert_equal brightcove_response['error'], 'nil'
  end

  def test_create_video_using_post_file
    FakeWeb.register_uri(:post,
                         'http://api.brightcove.com/services/post',
                         :body => File.join(File.dirname(__FILE__), 'fakeweb', 'create_video_response.json'),
                         :content_type => "application/json")

    brightcove = Brightcove::API.new('0Z2dtxTdJAxtbZ-d0U7Bhio2V1Rhr5Iafl5FFtDPY8E.')
    brightcove_response = brightcove.post_file('create_video',
      File.join(File.dirname(__FILE__), 'fakeweb', 'movie.mov'),
      :video => {:shortDescription => "Short Description", :name => "Video"})

    assert brightcove_response.has_key?('result')
    assert_equal '653155417001', brightcove_response['result'].to_s
    assert_equal brightcove_response['error'], nil
  end
end
