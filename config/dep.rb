require File.expand_path("#{File.dirname(__FILE__)}/../lib/dep")

Dep.gem do
  
  rake '=0.8.7', :require => %w(rake)
  rspec '=1.3.0'
end

Dep.gemspec do

  author 'Winton Welsh'
  email 'mail@wintoni.us'
  name 'dep'
  homepage "http://github.com/winton/#{name}"
  root File.expand_path("#{File.dirname(__FILE__)}/../")
  summary "Dependency manager"
  version '0.1.0'
end

Dep.profile do
  
  rakefile :require => %w(lib/dep/tasks) do
    rake :require => %w(rake/gempackagetask)
    rspec :require => %w(spec/rake/spectask)
  end
  
  spec_helper :require => %w(lib/dep pp)
end