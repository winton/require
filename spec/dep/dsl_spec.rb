require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

class Dep
  describe Dsl do
    
    it "should store method calls and a value, options array" do
      dsl = Dep::Dsl.new
      dsl.call { a 1, 2, 3 }
      dsl.should == [[:a, 1, 2, 3]]
    end
    
    it "should store child blocks" do
      dsl = Dep::Dsl.new
      dsl.call do
        a 1 do
          b 2
        end
      end
      dsl.should == [[:a, 1, [[:b, 2]]]]
    end
    
    it "should be able to retrieve a value from the block" do
      dsl = Dep::Dsl.new
      dsl.call do
        a 1
        b a
      end
      dsl.should == [[:a, 1], [:b, 1]]
    end
    
    it "should provide a get method" do
      dsl = Dep::Dsl.new
      dsl.call do
        a 1 do
          b 2
        end
      end
      dsl.get(:a).should == [:a, 1, [[:b, 2]]]
      dsl.get(:a, 1).should == [:a, 1, [[:b, 2]]]
      dsl.get(:b).should == nil
      dsl.get(:a).get(:b).should == [:b, 2]
      dsl.get(:a).get(:b).get(:c).should == nil
    end
    
    it "should provide an all method" do
      dsl = Dep::Dsl.new
      dsl.call do
        a 1
        a 2 do
          b 3
          b 4
        end
      end
      dsl.all(:a).should == [[:a, 1], [:a, 2, [[:b, 3], [:b, 4]]]]
      dsl.all(:b).should == []
      dsl.all(:a).all(:b).should == [[:b, 3], [:b, 4]]
    end
    
    it "should" do
      Dep do
        gem :active_wrapper, '=0.2.3' do
          require :active_wrapper
        end
        
        gemspec do
          author 'Winton Welsh'
          email 'mail@wintoni.us'
          dependencies do
            gem :active_wrapper
          end
          name 'gem_template'
          homepage "http://github.com/winton/#{name}"
          root File.expand_path("#{File.dirname(__FILE__)}/../")
          summary ""
          version '0.1.0'
        end
        
        bin do
          require 'lib/gem_template'
          gem :active_wrapper do
            require 'something'
          end
        end
      end
      Dep.class_eval do
        debug @@dsl
      end
      
    end
  end
end