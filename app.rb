#!/usr/bin/env ruby
# Id$ nonnax 2022-04-25 22:40:25 +0800
require_relative 'lib/mapa'

# Matcha.settings[:views]='views'

App = Mapa do
  on '/tv' do
    get do
      erb 'watch:tv', title: 'tv time'
    end
  end
  on '/:any' do |param|
    get do
      erb 'watch:movie', title: 'movie time'
    end
  end
  on '/' do
    post do
      erb 'see:index', title: 'welcome'
    end
    not_found do
      erb 'du notto whatto do'
    end
  end
  not_found do
    erb 'notto foundo'
  end
end
