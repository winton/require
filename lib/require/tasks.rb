desc "Package gem"
Rake::GemPackageTask.new(Require.instance) do |pkg|
  pkg.gem_spec = Require.instance
end

namespace :gem do
  desc "Install gem"
  task :install do
    Rake::Task['clobber_package'].invoke
    Rake::Task['gem'].invoke
    `sudo gem uninstall #{Require.name} -x`
    `sudo gem install pkg/#{Require.name}*.gem`
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
    $stdout.puts "Use sudo?"
    use_sudo = $stdin.gets.downcase[0..0] == 'y'
    $stdout.puts "Generate documentation?"
    gen_docs = $stdin.gets.downcase[0..0] == 'y'
    Require.all(:gem).sort { |a,b| a.name.to_s <=> b.name.to_s }.each do |dsl|
      cmd = "gem install #{dsl.name} -v '#{dsl.version}'"
      cmd = "#{'sudo ' if use_sudo}#{cmd} #{'--no-ri --no-rdoc' unless gen_docs}"
      $stdout.puts cmd
      system cmd
    end
  end
end

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir["#{Require.root}/spec/**/*_spec.rb"]
end
