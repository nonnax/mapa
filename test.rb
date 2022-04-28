#!/usr/bin/env ruby
# Id$ nonnax 2022-04-24 19:13:24 +0800
require 'rack'
require 'rack/test'
require 'test/unit'

OUTER_APP = Rack::Builder.parse_file("config.ru").first

class TestApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  def test_root
    get "/"
     assert_equal last_response.status, 404
     assert_equal last_response.body, 'notto foundo'
  end

  def test_root_login
    get "/login/name"
     assert_equal last_response.status, 200
     assert last_response.body.include?('name')
    post "/login/name"
     assert_equal last_response.status, 404
     assert_equal last_response.body, 'du notto whatto do'
  end

  def test_normal
    get "/tv"
     assert_equal last_response.status, 200
  end

  def test_any
    get "/anysegment", options: 'default'
     assert last_response.ok?
     assert_equal last_response.status, 200
     assert last_response.body.match?('default')
  end

  def test_not_found
    get "/first/second"
     assert_equal last_response.status, 404
     assert_equal last_response.body, 'notto foundo'
  end
end
