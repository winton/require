require 'rubygems'
require "#{File.dirname(__FILE__)}/require/dsl"
require "#{File.dirname(__FILE__)}/require/gemspec"

class Require
  
  @dsl = {}
  @gemspec = {}
  
  class <<self
  
    def all(*args)
      dsl.all *args
    end
  
    def call(&block)
      dsl(true).call &block
    end
    
    def dsl(force=false)
      @dsl[root(force)] ||= Dsl.new
    end
  
    def get(*args)
      dsl.get *args
    end
  
    def gemspec
      (@gemspec[root] ||= Gemspec.new).instance
    end
  
    def name
      Gemspec.name
    end
  
    def method_missing(method, value=nil, options=nil)
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
    
    def require!(paths)
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
  
    def reset(&block)
      @dsl = {}
      call &block
    end
  
    def root(force=false)
      paths = caller.collect do |p|
        File.expand_path(p.split(':').first)
      end
      path = paths.detect do |p|
        !p.index(/\/require[-\.\d]*\/lib\//) &&
        !p.include?('/rubygems/specification.rb') &&
        !p.include?('/lib/rake/') && 
        !p.include?('/lib/spec/')
      end
      paths = @dsl.keys.sort { |a,b| b.length <=> a.length }
      if force
        File.dirname(path)
      else
        paths.detect { |p| path[0..p.length-1] == p }
      end
    end
  
    private
  
    def dir_exists?(path)
      File.exists?(path) && File.directory?(path)
    end
  
    def file_exists?(path)
      (File.exists?(path) && File.file?(path)) ||
      (File.exists?("#{path}.rb") && File.file?("#{path}.rb"))
    end
  
    def load_path!(paths)
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
  
    def require_gem!(name, overwrite_version=nil, overwrite_dsl=nil)
      gem = get(:gem, name)
      if gem
        if overwrite_version || gem.version
          Kernel.send :gem, name.to_s, overwrite_version || gem.version
        else
          Kernel.send :gem, name.to_s
        end
        if overwrite_dsl || gem.dsl
          (overwrite_dsl || gem.dsl).all(:require).each do |dsl|
            require! dsl.path
          end
        end
      end
    end
  end
end

def Require(&block)
  Require.call &block
end
