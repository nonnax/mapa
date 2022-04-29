#!/usr/bin/env ruby
# Id$ nonnax 2022-04-25 22:40:25 +0800
require_relative 'lib/mapr'

# Mapa.settings[:views]='views'

$sum = 0

Thread.new do # trivial example work thread
  loop do
     sleep 0.12
     $sum += 1
  end
end

App = Mapr do

  on '/thread' do
    res.write "Testing background work thread: sum is #{$sum}"
  end

  on '/tv' do |params|
    get do
      session[:name]='mapa'
      erb 'watch:tv:', title: 'tv time'
    end
  end

  on '/login/:name' do |name, params|
    get do
      session[:name]=name
      erb 'welcome:'+session[:name]+String(params), title: 'welcome'
    end
    # not_found(405) do
      # erb 'du notto whatto do'
    # end
  end

  on '/:any' do |any, param|
    get do
      erb 'watch:' + String(session[:name] || 'movie')+String(param), title: 'movie time'
    end
  end

  on '/' do
    get do
      res.redirect '/thread'
    end
  end

  not_found do
    erb 'notto foundo'
  end
end
