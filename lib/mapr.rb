#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-25 22:35:06 +0800
require_relative 'view'

class Mapr
  H=Hash.new{|h,k| h[k]=k.transform_keys(&:to_sym)}
  ALLOWED=Hash[[301, 302, 303,307].product([false])];  ALLOWED.default=true

  class Response < Rack::Response; end

  attr :res, :req, :env, :map, :captures

  def initialize(&block)
    @block = block
  end

  def on(u)
    return if @stop || !match(u)

    run{ yield(*[*captures, H[req.params] ]) }
    if res.body.empty? && ALLOWED[res.status]
      res.status = 405
      res.write 'Method Not Allowed'
    end
    halt res.finish
  end

  def match(u)
    req.path_info.match(pattern(u))
       .tap { |md| @captures = Array(md&.captures) }
  end

  def pattern(u)
    u.gsub(/:\w+/) { '([^/?#]+)' }
     .then { |comp| %r{^#{comp}/?$} }
  end

  def run(status = nil)
    return if @stop
    @stop = true
    res.status = status if status
    yield
  end

  def get; yield if req.get? end

  def post; yield if req.post? end

  def put; yield if req.put? end

  def delete; yield if req.delete? end

  def not_found(status = 404, &block) run(status, &block) end

  def call!(env)
    @env = env
    @req = Rack::Request.new(env)
    @res = Rack::Response.new
    @stop = false
    catch(:halt) do
      instance_eval(&@block)
      not_found { res.write 'Not Found' }
      res.finish
    end
  end

  def call(env)
    dup.call!(env)
  end

  def halt(response)
    throw :halt, response
  end

  def session
    env['rack.session'] || raise('You need to set up a session middleware. `use Rack::Session`')
  end
end

def Mapr(&block)
  Mapr.new(&block)
end
