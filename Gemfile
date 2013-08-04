# vim: set ts=2 sw=2 ai et syntax=ruby:
source 'https://rubygems.org'

puppet_version = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : '~> 3'
hiera_spec_gem = ENV.key?('HIERA_SPEC_GEM') ? ENV['HIERA_SPEC_GEM'] : 'hiera-puppet-helper'
hiera_spec_gem_version =  ENV.key?('HIERA_SPEC_GEM_VERSION') ? ENV['HIERA_SPEC_GEM_VERSION'] : '1.0.1'

# common rspec dependencies
gem "mocha", "0.13.2"
gem "rspec-core", "2.12.2"
gem "rspec", "2.12.0"
gem "rspec-expectations", "2.12.1"
gem "rspec-mocks", "2.12.2"

gem 'puppet', puppet_version

# Code coverage
# https://coveralls.io/docs/ruby
gem "coveralls", :require => false

## Puppet 2.7 does not include hiera.
if puppet_version =~ /^([^0-9]+)?([^\.]|)2(\..*?)$/
  gem 'hiera'
  gem 'hiera-puppet'
end

gem hiera_spec_gem, hiera_spec_gem_version

# rspec-puppet loads puppetlabs_spec_helper/puppetlabs_spec/puppet_internals
# but fails to list it as a dependency
gem 'puppetlabs_spec_helper'
