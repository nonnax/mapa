#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-25 22:35:06 +0800
require_relative 'view'

class Mapr
  H=Hash.new{|h,k| h[k]=k.transform_keys(&:to_sym)}
  class Response < Rack::Response; end

  attr :res, :req, :env, :map, :captures

  def initialize(&block)
    @block = block
  end

  def on(u)
    return if @stop || !match(u)

    run{ yield(*[*captures, H[req.params] ]) }
    not_found(405) { res.write 'Method Not Allowed' }
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

  def run(status = 200)
    return if @stop

    res.status = status
    yield
    @stop = true
  end

  def get(&block)
    run(&block) if req.get?
  end

  def post(&block)
    run(&block) if req.post?
  end

  def put(&block)
    run(&block) if req.put?
  end

  def delete(&block)
    run(&block) if req.delete?
  end

  def not_found(status = 404, &block)
    run(status, &block)
  end

  def call(env)
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
