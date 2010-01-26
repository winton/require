require 'rubygems'
require "#{File.dirname(__FILE__)}/dep/dsl"
require "#{File.dirname(__FILE__)}/dep/gemspec"

class Dep
  
  @@gem = Dsl.new
  @@gemspec = Dsl.new
  @@gemspec_instance = Gemspec.new
  @@profile = Dsl.new
  
  def self.gem(&block)
    @@gem.call &block
  end
  
  def self.gemspec(&block)
    @@gemspec.call &block
  end
  
  def self.gemspec_instance
    @@gemspec_instance.instance
  end
  
  def self.name
    @@gemspec_instance.name
  end
  
  def self.method_missing(method, value=nil, options=nil)
    method = method.to_s
    if method.include?('!')
      method = method.gsub!('!', '').intern
      if profile[method]
        version, options, children = profile[method]
        children.each do |name, (overwrite_version, merge_options)|
          require_gem! name, overwrite_version, merge_options
        end
        require! options[:require]
      elsif gem[method]
        require_gem! method
      end
    else
      raise "Dep##{method} does not exist"
    end
  end
  
  def self.profile(&block)
    @@profile.call &block
  end
  
  def self.root
    @@gemspec_instance.root
  end
  
  private
  
  def self.file_exists?(path)
    (File.exists?(path) && File.file?(path)) ||
    (File.exists?("#{path}.rb") && File.file?("#{path}.rb"))
  end
  
  def self.require_gem!(name, overwrite_version=nil, merge_options={})
    version, options = gem.get(name)
    version = overwrite_version || version
    options = options.merge(merge_options)
    Kernel.send :gem, name.to_s, version
    require! options[:require]
  end
  
  def self.require!(paths)
    return unless paths
    [ paths ].flatten.each do |path|
      path_with_root = "#{root}/#{path}"
      if file_exists?(path_with_root)
        Kernel.require path_with_root
      else
        Kernel.require path
      end
    end
  end
end