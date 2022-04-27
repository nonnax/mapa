require 'kramdown'
class Mapa
  def self.settings; @settings ||= Hash.new{|h,k|h[k]={}} end 
  settings[:views]=:views
  settings[:layout]=:layout

  module View
    
    PATH=Hash.new{|h,k| h[k]=File.expand_path("#{Mapa.settings[:views]}/#{k}.erb", Dir.pwd)}
    
    def erb(doc, **locals)
      doc, layout = prepare(doc, **locals)
      s=render(layout, **locals){
         render(doc, **locals)
      }
      res.write s
    end
    
    def render(text, **opts)
      new_b=binding.dup.instance_eval do
        tap{ opts.each{|k,v| local_variable_set k, v} }
      end
      ERB.new(text, trim_mode: '%').result(new_b)
    end
        
    def prepare(doc, **locals)
      res.headers[Rack::CONTENT_TYPE] ||= 'text/html; charset=utf8;'
      l=PATH[Mapa.settings[:layout]]
      if doc.is_a?(Symbol)
        doc = PATH[doc]       
        doc= _cache[doc]
      end
      layout = _cache[l] rescue '<%=yield%>'
      [doc, layout]
    end

    def _cache
      Thread.current[:_view_cache] ||= Hash.new{|h,k| h[k]=IO.read(k) }
    end    
  end
  include View
end
