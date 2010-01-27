class Dep
  class Gemspec
    
    def clean_paths(paths, more=nil)
      paths.collect { |p| p.gsub("#{root}/#{more}", '') }
    end
    
    def executables
      clean_paths Dir["#{root}/bin/*"], 'bin/'
    end
    
    def extra_doc_files
      clean_paths Dir["#{root}/README.*"]
    end
    
    def files
      ignore = File.read("#{root}/.gitignore").split("\n").collect do |path|
        "#{root}/#{path.strip}"
      end
      clean_paths (Dir["#{root}/**/*"] - Dir[*ignore])
    end
    
    def instance
      
      defaults = {
        :executables => executables,
        :extra_rdoc_files => extra_doc_files,
        :files => files,
        :has_rdoc => false,
        :platform => Gem::Platform::RUBY,
        :require_path => 'lib'
      }
      
      ::Gem::Specification.new do |s|
        Dep.get(:gemspec).all.each do |(option, value)|
          case option
          when :dependencies then
            value.all(:gem).each do |dependency|
              gem = Dep.get(:gem, dependency.name)
              version = dependency.version || (gem.version rescue nil)
              s.add_dependency(dependency.name.to_s, version)
            end
          else
            if s.respond_to?("#{option}=")
              s.send "#{option}=", value || defaults[option]
              defaults[option] = nil
            end
          end
        end
        defaults.each do |option, value|
          s.send("#{option}=", value) if value
        end
      end
    end
    
    def name
      Dep.get(:gemspec).get(:name)[1] rescue nil
    end
    
    def root
      Dep.get(:gemspec).get(:root)[1] rescue nil
    end
  end
end