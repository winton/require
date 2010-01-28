desc "Package gem"
Rake::GemPackageTask.new(Require.instance) do |pkg|
  pkg.gem_spec = Require.instance
end

desc "Install gem"
task :install do
  Rake::Task['gem'].invoke
  `sudo gem uninstall #{Require.name} -x`
  `sudo gem install pkg/#{Require.name}*.gem`
  `rm -Rf pkg`
end

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir["#{Require.root}/spec/**/*_spec.rb"]
end
