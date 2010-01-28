require "#{File.dirname(__FILE__)}/spec_helper"

describe Dep do
  
  before(:all) do
    @fixture = File.dirname(__FILE__) + '/fixture'
    Dep.reset do
      gem :rake, '=0.8.7'
      gem(:rspec, '=1.3.0') { require 'spec' }
      
      rakefile do
        require 'test'
        load_path File.dirname(__FILE__) + '/fixture'
        gem(:rake) { require 'rake/gempackagetask' }
        gem(:rspec, '>1.2.9') { require 'spec/rake/spectask' }
      end
    end
  end
  
  it "should provide a load_path! method" do
    Dep.send :load_path!, @fixture
    $:.include?(@fixture).should == true
  end
  
  it "should provide a require_gem! method" do
    Kernel.should_receive(:gem).with('rspec', '=1.3.0')
    Dep.should_receive(:require!).with('spec')
    Dep.send :require_gem!, :rspec
  end
  
  it "should provide a require_gem! method with optional overwrite methods" do
    Kernel.should_receive(:gem).with('rspec', '>1.2.9')
    Dep.should_receive(:require!).with('spec/rake/spectask')
    dsl = Dep.get(:rakefile).get(:gem, :rspec).last
    Dep.send :require_gem!, :rspec, '>1.2.9', dsl
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
    Dep.should_receive(:require_gem!).with(:rake, nil, [[:require, "rake/gempackagetask"]])
    Dep.should_receive(:require_gem!).with(:rspec, '>1.2.9', [[:require, "spec/rake/spectask"]])
    Dep.should_receive(:load_path!).with(@fixture)
    Dep.rakefile!
  end
end