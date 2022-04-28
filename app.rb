#!/usr/bin/env ruby
# Id$ nonnax 2022-04-25 22:40:25 +0800
require_relative 'lib/mapa'

# Mapa.settings[:views]='views'

App = Mapa do
  on '/tv' do |params|
    get do
      session[:name]='mapa'
      erb 'watch:tv:', title: 'tv time'
    end
  end

  on '/:any', option: 'default' do |any, param|
    get do
      erb 'watch:' + String(session[:name] || 'movie')+String(param), title: 'movie time'
    end
  end

  on '/login/:name' do |name, params|
    get do
      session[:name]=name
      erb 'welcome:'+session[:name]+String(params), title: 'welcome'
    end
    not_found do
      erb 'du notto whatto do'
    end
  end

  not_found do
    erb 'notto foundo'
  end
end
