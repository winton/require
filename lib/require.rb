require 'rubygems'
require "#{File.dirname(__FILE__)}/require/dsl"
require "#{File.dirname(__FILE__)}/require/gemspec"

class Require
  
  @@dsl = Dsl.new
  @@gemspec = Gemspec.new
  @@root = nil
  
  def self.all(*args)
    @@dsl.all *args
  end
  
  def self.call(root=nil, &block)
    @@root = File.expand_path(root) if root
    @@dsl.call &block
  end
  
  def self.get(*args)
    @@dsl.get *args
  end
  
  def self.instance
    @@gemspec.instance
  end
  
  def self.name
    @@gemspec.name
  end
  
  def self.method_missing(method, value=nil, options=nil)
    method = method.to_s
    if method.include?('!')
      method = method.gsub!('!', '').intern
      gem = get(:gem, method)
      profile = get(method)
      if profile
        profile.dsl.each do |dsl|
          if dsl.gem?
            require_gem! dsl.name, dsl.version, dsl.dsl
          elsif dsl.load_path?
            load_path! dsl.path
          elsif dsl.require?
            require! dsl.path
          end
        end
      elsif gem
        require_gem! gem.name
      end
    else
      raise "Require##{method} does not exist"
    end
  end
  
  def self.reset(root=nil, &block)
    @@dsl = Dsl.new
    @@gemspec = Gemspec.new
    call root, &block
  end
  
  def self.root
    @@root
  end
  
  private
  
  def self.file_exists?(path)
    (File.exists?(path) && File.file?(path)) ||
    (File.exists?("#{path}.rb") && File.file?("#{path}.rb"))
  end
  
  def self.dir_exists?(path)
    File.exists?(path) && File.directory?(path)
  end
  
  def self.load_path!(paths)
    return unless paths
    [ paths ].flatten.each do |path|
      path_with_root = "#{root}/#{path}"
      if root && dir_exists?(path_with_root)
        $: << path_with_root
      else
        $: << path
      end
    end
  end
  
  def self.require_gem!(name, overwrite_version=nil, overwrite_dsl=nil)
    gem = get(:gem, name)
    if gem
      Kernel.send :gem, name.to_s, overwrite_version || gem.version
      (overwrite_dsl || gem.dsl).all(:require).each do |dsl|
        require! dsl.path
      end
    end
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

def Require(root=nil, &block)
  Require.call root, &block
end
