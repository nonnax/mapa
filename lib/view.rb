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
        self.tap{ opts.each{|k,v| local_variable_set k, v} }
      end
      ERB.new(text, trim_mode: '%').result(new_b)
    end
        
    def prepare(doc, **locals)
      res.headers[Rack::CONTENT_TYPE] ||= 'text/html; charset=utf8;'
      l=PATH[Mapa.settings[:layout]]
      if doc.is_a?(Symbol)
        doc=PATH[doc]       
        doc=IO.read(doc)
      end
      layout=IO.read(l) rescue '<%=yield%>'
      [doc, layout]
    end
    
  end
  include View
end
