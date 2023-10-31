# frozen_string_literal: true
require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker

RSpec.configure do |c|
  c.mock_with :rspec
end

require 'beaker-rspec/spec_helper'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  c.before :suite do
    puppet_module_install(
      source: module_root,
      module_name: 'nfs'
    )
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install', 'puppetlabs-concat'), acceptable_exit_codes: [0, 1]
    end
  end
end
