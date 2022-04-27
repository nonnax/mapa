#!/usr/bin/env ruby
# Id$ nonnax 2022-04-25 22:35:06 +0800
require_relative 'view'

class Mapa
  class Response<Rack::Response; end
  attr :res, :req, :env, :map, :captures
  def initialize(&block)
    @block=block
  end
  def on(u)
    return if @stop || !match(u)
    yield(*captures)
    not_found(405){ res.write 'Method Not Allowed' }
    halt res.finish
  end
  def match(u)
    req.path_info.match(pattern(u))
    .tap{|md| @captures=Array(md&.captures) }
  end
  def pattern(u)
    u.gsub(/:\w+/) { '([^/?#]+)' }
     .then { |comp| %r{^#{comp}/?$} }
  end
  
  def run(status=200)
    return if @stop
    res.status=status
    yield
    @stop=true
  end
  def get; run{ yield } if req.get? end
  def post; run{ yield } if req.post? end
  def put; run{ yield } if req.put? end
  def delete; run{ yield } if req.delete? end
  def not_found(status=404);  run(status){ yield } end
  
  def halt(response)
    throw :halt, response
  end
  def call(env)
    @env=env
    @req=Rack::Request.new(env)
    @res=Rack::Response.new
    @stop=false
    catch(:halt){
      instance_eval(&@block)
      not_found{res.write 'Not Found'}
      res.finish
    }    
  end
end

def Mapa(&block)
  Mapa.new(&block)
end
