require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

class Dep
  describe Dsl do
    
    it "should store method calls and a value, options array" do
      dsl = Dep::Dsl.new
      dsl.call { a 1 }
      dsl.should == {:a=>[1, {}, {}]}
    end
    
    it "should handle options" do
      dsl = Dep::Dsl.new
      dsl.call { a :require => [ 'require' ] }
      dsl.should == {:a=>[nil, { :require => [ 'require' ] }, {}]}
    end
    
    it "should store child blocks" do
      dsl = Dep::Dsl.new
      dsl.call do
        a 1 do
          b 2
        end
      end
      dsl.should == {:a=>[1, {}, {:b=>[2, {}, {}]}]}
    end
    
    it "should be able to retrieve a value from the block" do
      dsl = Dep::Dsl.new
      dsl.call do
        a 1
        b a
      end
      dsl.should == {:a=>[1, {}, {}], :b=>[1, {}, {}]}
    end
    
    it "should provide a get method for exception-free data retrieval" do
      dsl = Dep::Dsl.new
      dsl.call { a 1 }
      dsl.get(:a).should == [ 1, {}, {} ]
      dsl.get(:a, 0).should == 1
      dsl.get(:fail).should == [ nil, {}, {} ]
    end
  end
end