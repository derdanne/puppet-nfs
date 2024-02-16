source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place, fake_version = nil)
  if place =~ %r{^(git[:@][^#]*)#(.*)}
    [fake_version, { git: Regexp.last_match(1), branch: Regexp.last_match(2), require: false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { path: File.expand_path(Regexp.last_match(1)), require: false }]
  else
    [place, { require: false }]
  end
end

group :test do
  gem 'metadata-json-lint',                                         require: false
  gem 'voxpupuli-test'
  gem 'puppet-blacksmith',                                          require: false, git: 'https://github.com/voxpupuli/puppet-blacksmith.git'
  gem 'puppet-strings',                                             require: false
  gem 'puppet-syntax',                                              require: false
  gem 'puppetlabs_spec_helper',                                     require: false
  gem 'semantic_puppet',                                            require: false
  gem 'rake',                                                       require: false
  gem 'rspec',                                                      require: false
  gem 'rspec-core',                                                 require: false
  gem 'rspec-puppet',                                               require: false, git: 'https://github.com/puppetlabs/rspec-puppet.git'
  gem 'rspec-puppet-facts',                                         require: false
  gem 'rspec-puppet-utils',                                         require: false
  gem 'rubocop',                                                    require: false
  gem 'rubocop-rspec',                                              require: false
  gem 'voxpupuli-release',                                          require: false, git: 'https://github.com/voxpupuli/voxpupuli-release-gem.git'
end

group :development do
  gem 'guard-rake',   require: false
end

if RUBY_VERSION >= '2.3.0'
  group :acceptance do
    gem 'beaker'
    gem 'beaker-puppet_install_helper'
    gem 'beaker-puppet'
    gem 'beaker-docker'
    gem 'beaker-rspec'
  end
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion.to_s, require: false, groups: [:test]
else
  gem 'facter', require: false, groups: [:test]
end

puppetversion = ENV['PUPPET_VERSION'].nil? ? '~> 4.0' : ENV['PUPPET_VERSION'].to_s
gem 'puppet', puppetversion, require: false, groups: [:test]

# vim:ft=ruby
