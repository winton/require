class Require
  module Tasks
    
    def self.set(*types)
      if types.include?(:ask_docs)
        $stdout.puts "Generate documentation?"
        @@gen_docs = $stdin.gets.downcase[0..0] == 'y'
      elsif types.include?(:docs)
        @@gen_docs = true
      elsif types.include?(:no_docs)
        @@gen_docs = false
      end
      if types.include?(:ask_sudo)
        $stdout.puts "Use sudo?"
        @@use_sudo = $stdin.gets.downcase[0..0] == 'y'
      elsif types.include?(:sudo)
        @@gen_docs = true
      elsif types.include?(:no_sudo)
        @@use_sudo = false
      end
    end
    
    def self.rm_pkg
      cmd = "rm -Rf pkg"
      $stdout.puts cmd
      system cmd
    end
    
    def self.run(cmd)
      cmd = "#{'sudo ' if @@use_sudo}#{cmd}#{' --no-ri --no-rdoc' unless @@gen_docs}"
      $stdout.puts cmd
      system cmd
    end
  end
end

desc "Package gem"
Rake::GemPackageTask.new(Require.instance) do |pkg|
  pkg.gem_spec = Require.instance
end

namespace :gem do
  desc "Install gem"
  task :install do
    Require::Tasks.rm_pkg
    Rake::Task['gem'].invoke
    Require::Tasks.set :docs, :ask_sudo
    Require::Tasks.run "gem uninstall #{Require.name} -x"
    Require::Tasks.run "gem install pkg/#{Require.name}*.gem"
    Require::Tasks.rm_pkg
  end
  
  desc "Push gem"
  task :push do
    Require::Tasks.rm_pkg
    Rake::Task['gem'].invoke
    Require::Tasks.set :docs, :no_sudo
    Require::Tasks.run "gem push pkg/#{Require.name}*.gem"
    Require::Tasks.rm_pkg
  end
end

desc "List gem dependencies"
task :gems do
  Require.all(:gem).sort { |a,b| a.name.to_s <=> b.name.to_s }.each do |dsl|
    puts "#{dsl.name} (#{dsl.version})"
  end
end

namespace :gems do
  desc "Install gem dependencies"
  task :install do
    Require::Tasks.set :ask_docs, :ask_sudo
    Require.all(:gem).sort { |a,b| a.name.to_s <=> b.name.to_s }.each do |dsl|
      Require::Tasks.run "gem install #{dsl.name}#{" -v '#{dsl.version}'" if dsl.version}"
    end
  end
end

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir["#{Require.root}/spec/**/*_spec.rb"]
end
