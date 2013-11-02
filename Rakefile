require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

gemspec = eval(File.read("donedone.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["donedone.gemspec"] do
  system "gem build donedone.gemspec"
  system "gem install donedone-#{DoneDone::VERSION}.gem"
end
