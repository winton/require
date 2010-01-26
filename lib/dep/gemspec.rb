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
      
      options = %w(
        author
        email
        executables
        extra_rdoc_files
        files
        has_rdoc
        homepage
        name
        platform
        summary
        version
      )
      
      ::Gem::Specification.new do |s|
        options.each do |option|
          option = option.intern
          s.send "#{option}=", Dep.gemspec.get(option, 0) || defaults[option]
        end
        
        Dep.profile.get(:gemspec).each do |(version, options, children)|
          s.add_dependency(name, version || Dep.gem.get(name, 0))
        end
      end
    end
    
    def name
      Dep.gemspec.get(:name, 0)
    end
    
    def root
      Dep.gemspec.get(:root, 0)
    end
  end
end