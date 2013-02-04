# vim: set ts=2 sw=2 ai et syntax=ruby:
source :rubygems

if ENV.key?('PUPPET_VERSION')
  puppet_version = ENV['PUPPET_VERSION']
else
  puppet_version = ['~> 2.7']
  #puppet_version = ['~> 3.0.0']
end

if ENV.key?('RSPEC_HIERA_PUPPET_VERSION')
  rspec_hiera_puppet_version = ENV['RSPEC_HIERA_PUPPET_VERSION']
else
  rspec_hiera_puppet_version = ['0.3.0']
  #rspec_hiera_puppet_version = ['1.0.0.test']
end

# common rspec dependencies
gem "mocha", "0.13.2"
gem "rspec-core", "2.12.2"
gem "rspec", "2.12.0"
gem "rspec-expectations", "2.12.1"
gem "rspec-mocks", "2.12.2"

gem 'puppet', puppet_version
gem 'rspec-hiera-puppet', rspec_hiera_puppet_version
#gem 'rspec-hiera-puppet', rspec_hiera_puppet_version, :path => File.join(
#  ENV['HOME'], 'git-repos', '3pp', 'rspec-hiera-puppet', 'pkg'
#)

# rspec-puppet loads puppetlabs_spec_helper/puppetlabs_spec/puppet_internals
# but fails to list it as a dependency
gem 'puppetlabs_spec_helper'
