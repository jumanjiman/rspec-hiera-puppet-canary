# vim: set ts=2 sw=2 ai et:
require 'pp'
describe 'canary::example' do
  bar_message = 'bar' # content from hieradata/common.yaml
  baz_message = 'baz' # content from hieradata/diff.example.com.yaml

  puppet_errors = [
    # in the tests below, we look for these specific errors that
    # indicate incompatibilities with hiera, puppet, or rspec-puppet
    %q{undefined method `empty_answer'}, # [1]
    %q{Could not find data item},        # [2]
  ]
  # [1] removed with https://github.com/puppetlabs/hiera/commit/480d86c6ec
  # [2] these canary tests below should *always* find data item

  # pretty print :hiera_config if environment variable is truthy
  if ENV.key?('PRETTY_PRINT') and /^(true|y(es)*)$/i.match ENV['PRETTY_PRINT']
    pretty_print = true
  else
    pretty_print = false
  end

  describe 'hiera config' do
    context 'by default, loads and uses hiera.yaml as-is' do
      it 'uses yaml backend' do
        hiera_config[:backends].should =~ ['yaml']
      end
    end
    context 'when let(:hiera_data) is used' do
      let(:hiera_data) {Hash.new}
      it 'uses rspec backend' do
        hiera_config[:backends].should =~ ['rspec', 'yaml']
      end
    end
  end

  describe 'yaml backend' do
    # do not let(:hiera_data), thereby forcing the shared
    # context to use a real hieradata lookup, which should return
    # the content content from common.yaml or <fqdn>.yaml
    { 'non_existent_fqdn' => bar_message, # from common.yaml
      'diff.example.com'  => baz_message, # from diff.example.com.yaml
    }.each do |fqdn, message|
      context "let(:facts) {{:fqdn => '#{fqdn}'}}" do
        let(:facts) {{:fqdn => fqdn}}

        # http://docs.puppetlabs.com/hiera/1/configuring.html#backends
        it 'should use yaml backend' do
          hiera_config[:backends].should =~ ['yaml']
        end

        # check for gem incompatibilities
        puppet_errors.each do |error|
          it "should not spew #{error}" do
            expect{should contain_notify('foo')}.to_not raise_error(
              Puppet::Error, /#{error}/
            )
          end
        end

        # the real goal
        it {should contain_notify('foo').with_message(message)}

        # ugly kludge for verifying content of hiera_config
        it {pp hiera_config} if pretty_print
      end
    end
  end

  describe 'rspec backend' do
    # use rspec backend to provide the message;
    # 1st, provide the same message as common.yaml
    # 2nd, provide a different message than common.yaml
    [bar_message, baz_message].each do |msg|
      as_symbol = {:foo_message  => msg} # hash with key "as" a symbol
      as_string = {'foo_message' => msg} # hash with key "as" a string

      # try using the hiera_data key as either a symbol or a string
      [as_symbol, as_string].each do |as_hash|
        context "let(:hiera_data) {#{as_hash}}" do
          # https://github.com/amfranz/rspec-hiera-puppet#basic
          let(:hiera_data) {as_hash}

          # http://docs.puppetlabs.com/hiera/1/configuring.html#backends
          it 'should use rspec and yaml backends' do
            hiera_config[:backends].should =~ ['rspec', 'yaml']
          end

          # The 'rspec' backend uses its configuration hash
          # as data store to look up data.
          # https://github.com/amfranz/rspec-hiera-puppet#advanced
          it "hiera_config[:rspec] is #{as_hash}" do
            hiera_config[:rspec].should == hiera_data
          end

          # check for gem incompatibilities
          puppet_errors.each do |error|
            it "should not spew #{error}" do
              expect{should contain_notify('foo')}.to_not raise_error(
                Puppet::Error, /#{error}/
              )
            end
          end

          # the real goal
          it {should contain_notify('foo').with_message(msg)}

          # ugly kludge for verifying content of hiera_config
          it {pp hiera_config} if pretty_print
        end
      end
    end
  end
end
