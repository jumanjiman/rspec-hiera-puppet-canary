hiera_spec_gem = ENV.key?('HIERA_SPEC_GEM') ? ENV['HIERA_SPEC_GEM'] : 'hiera-puppet-helper'

gems = [
  'rspec-puppet',
  hiera_spec_gem,
  'hiera',
]
begin
  gems.each {|gem| require gem}
rescue Exception => e
  puts '=' * e.message.length
  puts e.message
  puts '=' * e.message.length
  exit(1)
end

module Helpers
  class Paths
    def self.fixture_path
      File.expand_path(File.join(__FILE__, '..', 'fixtures'))
    end
  end

  extend RSpec::SharedContext
  def hiera_config_content
    # load content from repo to support testing dynamic puppet environments
    fixture_path = Helpers::Paths.fixture_path
    h_config = YAML.load_file(File.join(fixture_path, 'files', 'hiera.yaml'))
    h_config[:yaml][:datadir] = File.join(fixture_path, 'hieradata')

    # use rspec-backend before other backends,
    # but only if author used 'let(:hiera_data)'
    if respond_to?(:hiera_data)
      # http://docs.puppetlabs.com/hiera/1/configuring.html#backends
      h_config[:backends].unshift('rspec') # rspec backend is first!

      # https://github.com/amfranz/rspec-hiera-puppet#advanced
      h_config[:rspec] = hiera_data # rspec backend gets data from its config
    end

    return h_config
  end

  # include Helpers to get this :hiera_config
  let(:hiera_config) {hiera_config_content}
end

RSpec.configure do |c|
  c.include Helpers   # use hiera_config in every context
  c.fail_fast = false # see output for all failures

  # rspec-puppet needs to know where to find fixtures
  c.module_path = File.join(Helpers::Paths.fixture_path, 'modules')
  c.manifest_dir = File.join(Helpers::Paths.fixture_path, 'manifests')

  c.before :each do
    # don't cache facts and environment between test cases
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store environment variables (to be restored later)
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}
  end

  c.after :each do
    # Restore environment variables
    @old_env.each_pair {|k, v| ENV[k] = v}
    to_remove = ENV.keys.reject {|key| @old_env.include? key }
    to_remove.each {|key| ENV.delete key }
  end
end
