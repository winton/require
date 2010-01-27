require File.expand_path("#{File.dirname(__FILE__)}/../lib/dep")

Dep do
  
  gem(:rake, '=0.8.7') { require 'rake' }
  gem(:rspec, '=1.3.0') { require 'rspec' }
  
  gemspec do
    author 'Winton Welsh'
    email 'mail@wintoni.us'
    name 'dep'
    homepage "http://github.com/winton/#{name}"
    root File.expand_path("#{File.dirname(__FILE__)}/../")
    summary "Dependency manager"
    version '0.1.2'
  end
  
  rakefile do
    gem(:rake) { require 'rake/gempackagetask' }
    gem(:rspec) { require 'spec/rake/spectask' }
    require 'lib/dep/tasks'
  end
end