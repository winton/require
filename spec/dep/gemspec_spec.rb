require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

class Dep
  describe Gemspec do
    
    it "should generate a valid gemspec instance" do
      Dep.reset do
        gem :rspec, '=1.3.0'
      
        gemspec do
          author 'Winton Welsh'
          dependencies do
            gem :rspec
          end
          email 'mail@wintoni.us'
          name 'gem_template'
          homepage "http://github.com/winton/#{name}"
          root File.expand_path("#{File.dirname(__FILE__)}/../fixture")
          summary "summary"
          version '0.1.0'
        end
      end
      
      FileUtils.mkdir_p(File.expand_path("#{File.dirname(__FILE__)}/../fixture/ignore_me"))
      
      s = Dep.instance
      s.authors.should == [ "Winton Welsh" ]
      s.date.should == Time.utc(Date.today.year, Date.today.mon, Date.today.mday, 8)
      s.default_executable.should == "bin"
      s.dependencies.should == [Gem::Dependency.new("rspec", Gem::Requirement.new(["= 1.3.0"]), :runtime)]
      s.email.should == 'mail@wintoni.us'
      s.executables.should == ["bin"]
      s.extra_rdoc_files.should == ["README.markdown"]
      s.files.should == ["bin", "bin/bin", "lib", "lib/lib.rb", "README.markdown"]
      s.homepage.should == "http://github.com/winton/gem_template"
      s.name.should == "gem_template"
      s.require_paths.should == ["lib"]
      s.summary.should == 'summary'
    end
  end
end