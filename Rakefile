#!/usr/bin/env ruby
# Id$ nonnax 2022-04-25 15:31:55 +0800
desc 'compile scss'
task :compile do
  Dir.chdir 'scss' do
    sh 'sass.rb style.scss > ../public/css/style.css'
  end
end

desc 'install gem'
task :install do
  sh 'gem build mapr.gemspec'
  sh 'sudo gem install mapr-0.0.1.gem'
end
