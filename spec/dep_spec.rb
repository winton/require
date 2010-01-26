require "#{File.dirname(__FILE__)}/spec_helper"

describe Dep do
  
  before(:all) do
    Dep.gem do
      rake '=0.8.7'
      rspec '=1.3.0', :require => 'spec'
    end
    
    Dep.profile do
      rakefile :require => 'test' do
        rake :require => %w(rake/gempackagetask)
        rspec '>1.2.9', :require => %w(spec/rake/spectask)
      end
    end
  end
  
  it "should provide a require_gem! method" do
    Kernel.should_receive(:gem).with('rspec', '=1.3.0')
    Dep.should_receive(:require!).with('spec')
    Dep.send :require_gem!, :rspec
  end
  
  it "should provide a require! method" do
    Kernel.should_receive(:require).with('spec')
    Dep.send :require!, 'spec'
  end
  
  it "should require gems through the bang shortcut" do
    Dep.should_receive(:require_gem!).with(:rspec)
    Dep.rspec!
  end
  
  it "should require profiles through the bang shortcut" do
    Dep.should_receive(:require!).with('test')
    Dep.should_receive(:require_gem!).with(:rake, nil, { :require => [ 'rake/gempackagetask' ]})
    Dep.should_receive(:require_gem!).with(:rspec, '>1.2.9', { :require => [ 'spec/rake/spectask' ]})
    Dep.rakefile!
  end
end