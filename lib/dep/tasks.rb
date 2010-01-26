desc "Package gem"
Rake::GemPackageTask.new(Dep.gemspec_instance) do |pkg|
  pkg.gem_spec = Dep.gemspec_instance
end

desc "Install gem"
task :install do
  Rake::Task['gem'].invoke
  `sudo gem uninstall #{Dep.name} -x`
  `sudo gem install pkg/#{Dep.name}*.gem`
  `rm -Rf pkg`
end

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir["#{Dep.root}/spec/**/*_spec.rb"]
end