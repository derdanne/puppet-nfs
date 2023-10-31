require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'metadata-json-lint/rake_task'
require 'puppet_blacksmith/rake_tasks'
require 'voxpupuli/release/rake_tasks'
require 'voxpupuli/test/rake_tasks'
require 'rubocop/rake_task'
require 'puppet-strings/tasks'

PuppetLint.configuration.send('disable_ensure_first_param')

RuboCop::RakeTask.new

PuppetLint::RakeTask.new :lint do |config|
  # Pattern of files to ignore
  config.ignore_paths = ['Gemfile', 'Rakefile', 'pkg/**/*', 'vendor/**/*', '.vendor/**/*', 'spec/**/*']

  # List of checks to disable
  config.disable_checks = ['disable_class_inherits_from_params_class', '140chars', 'documentation', 'disable_single_quote_string_with_variables']

  # Should puppet-lint prefix it's output with the file being checked,
  # defaults to true
  config.with_filename = false

  # Should the task fail if there were any warnings, defaults to false
  config.fail_on_warnings = true

  # Format string for puppet-lint's output (see the puppet-lint help output
  # for details
  config.log_format = '%{filename} - %{message}'

  # Print out the context for the problem, defaults to false
  config.with_context = true

  # Enable automatic fixing of problems, defaults to false
  config.fix = false

  # Show ignored problems in the output, defaults to false
  config.show_ignored = true

  # Compare module layout relative to the module root
  config.relative = true
end

desc 'Run acceptance tests'
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

desc 'Run metadata_lint, lint, syntax, and spec tests.'
task test: [
  :metadata_lint,
  :lint,
  :syntax,
  :spec
]
