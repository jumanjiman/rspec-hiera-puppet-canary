# rspec-hiera-puppet-canary

rspec-hiera-puppet-canary is a puppet module that serves as a
reference implementation of using rspec-hiera-puppet for unit tests.

This provides examples of what works and doesn't work for me using
[rspec-hiera-puppet](https://github.com/amfranz/rspec-hiera-puppet).

## Use cases

### Dynamic hiera configuration

In Puppet versions before 3.0, the path to Hiera's config file, `hiera.yaml`,
is hard-coded.

If you're using [dynamic Puppet environments with git branches](https://puppetlabs.com/blog/git-workflow-and-puppet-environments)
with Puppet 2.7, then adding rspec-hiera tests is a challenge.
rspec-hiera-puppet enables you to easily load `hiera.yaml` content
from an arbitrary file, such as a file within your git repo.

The rspec-hiera-puppet-canary module includes an
example of loading `hiera.yaml` from a fixture
in `spec/spec_helper.rb`. Rspec unit tests in
`spec/classes/example_spec.rb` show how to assert whether the
hiera config is correctly loaded.

rspec-hiera-puppet does a good job of loading the hiera config,
and we use it at my day job for exactly this use case.

### Stubbing hiera data

rspec-hiera-puppet is supposed to enable a test author to stub
hiera data in unit tests by writing `let(:hiera_data) { {key => value} }`.
This doesn't work at the moment and is the main reason for
the rspec-hiera-puppet-canary module.

## Canary tests

### Current status

[![Build Status](https://travis-ci.org/jumanjiman/rspec-hiera-puppet-canary.png?branch=master)](https://travis-ci.org/jumanjiman/rspec-hiera-puppet-canary)

The **canary tests indicate incompatibilities in the code
between rspec-hiera-puppet and its dependencies**.

For example, rspec-hiera-puppet currently depends on code from
hiera-puppet as well as puppet 3. However,
[The angry guide to Puppet 3](http://somethingsinistral.net/blog/the-angry-guide-to-puppet-3/#hiera-api-changes)
says:

> ...the hiera-puppet backend has been deprecated and is no longer
> necessary. In fact, having this around might make the world
> blow up. The relevant functions have also been moved into core
> Puppet, so you should not have this installed.

From the [official PuppetLabs hiera-puppet repo](https://github.com/puppetlabs/hiera-puppet):

> Hiera-puppet is in end-of-life
>
> As of the release of Puppet 3.0.0, hiera-puppet has been
> incorporated into the puppet codebase. The standalone
> hiera-puppet is only needed for releases of Puppet prior to
> 3.0.0, which are all in bug-fix only mode. The 1.x branch is
> for those older versions of puppet and is only open for urgent
> bug-fixes. However, do not submit fixes against this repository.

### Setup

First, ensure your system has bundler and rake, then
assign values to environment variables to use the current
versions of puppet and rspec-hiera-puppet along with their
dependencies:

```bash
export RSPEC_HIERA_PUPPET_VERSION='1.0.0'
export PUPPET_VERSION='3.0.2'
bundle update
```

The above commands should produce output similar to:

```
Fetching gem metadata from http://rubygems.org/.........
Fetching gem metadata from http://rubygems.org/..
Using rake (10.0.3) 
Using diff-lcs (1.1.3) 
Using facter (1.6.17) 
Using hiera (1.0.0) 
Using hiera-puppet (1.0.0) 
Using metaclass (0.0.1) 
Using mocha (0.13.2) 
Using puppet (3.0.2) 
Using rspec-core (2.12.2) 
Using rspec-expectations (2.12.1) 
Using rspec-mocks (2.12.2) 
Using rspec (2.12.0) 
Using rspec-puppet (0.1.6) 
Using puppetlabs_spec_helper (0.4.0) 
Using rspec-hiera-puppet (1.0.0) 
Using bundler (1.2.3) 
Your bundle is updated! Use `bundle show [gemname]` to see where a bundled gem is installed.
```

### Run the tests

Run the tests with...

    rake spec

...which (with the gem versions listed above) produces output similar to:

```
canary
  should contain Class[canary::example]

canary::example
  hiera config
    by default, loads and uses hiera.yaml as-is
      uses yaml backend
    when let(:hiera_data) is used
      uses rspec backend
  yaml backend
    let(:facts) {{:fqdn => 'non_existent_fqdn'}}
      should use yaml backend
      should not spew undefined method `empty_answer'
      should not spew Could not find data item
      should contain Notify[foo] with message => "bar" (FAILED - 1)
    let(:facts) {{:fqdn => 'diff.example.com'}}
      should use yaml backend
      should not spew undefined method `empty_answer'
      should not spew Could not find data item
      should contain Notify[foo] with message => "baz" (FAILED - 2)
  rspec backend
    let(:hiera_data) {{:foo_message=>"bar"}}
      should use rspec and yaml backends
      hiera_config[:rspec] is {:foo_message=>"bar"}
      should not spew undefined method `empty_answer'
      should not spew Could not find data item
      should contain Notify[foo] with message => "bar" (FAILED - 3)
    let(:hiera_data) {{"foo_message"=>"bar"}}
      should use rspec and yaml backends
      hiera_config[:rspec] is {"foo_message"=>"bar"}
      should not spew undefined method `empty_answer'
      should not spew Could not find data item
      should contain Notify[foo] with message => "bar" (FAILED - 4)
    let(:hiera_data) {{:foo_message=>"baz"}}
      should use rspec and yaml backends
      hiera_config[:rspec] is {:foo_message=>"baz"}
      should not spew undefined method `empty_answer'
      should not spew Could not find data item
      should contain Notify[foo] with message => "baz" (FAILED - 5)
    let(:hiera_data) {{"foo_message"=>"baz"}}
      should use rspec and yaml backends
      hiera_config[:rspec] is {"foo_message"=>"baz"}
      should not spew undefined method `empty_answer'
      should not spew Could not find data item
      should contain Notify[foo] with message => "baz" (FAILED - 6)

hiera.yaml
  md5sum should == b01e596e22abe6bfdb508f0f34066c7d
  should contain exactly "yaml"
  should == "/opt/puppet/environments/%{::environment}/hieradata"
  should contain exactly "%{::fqdn}" and "common"

hieradata
  common.yaml
    should contain :foo_message => 'bar'
    should contain 'foo_message' => 'bar'
  diff.example.com.yaml
    should contain :foo_message => 'baz'
    should contain 'foo_message' => 'baz'

Failures:

  1) canary::example yaml backend let(:facts) {{:fqdn => 'non_existent_fqdn'}} 
     Failure/Error: it {should contain_notify('foo').with_message(message)}
       expected that the catalogue would contain Notify[foo] with message set to `"bar"` but it is set to `"broken"` in the catalogue
     # ./spec/classes/example_spec.rb:62:in `block (5 levels) in <top (required)>'

  2) canary::example yaml backend let(:facts) {{:fqdn => 'diff.example.com'}} 
     Failure/Error: it {should contain_notify('foo').with_message(message)}
       expected that the catalogue would contain Notify[foo] with message set to `"baz"` but it is set to `"broken"` in the catalogue
     # ./spec/classes/example_spec.rb:62:in `block (5 levels) in <top (required)>'

  3) canary::example rspec backend let(:hiera_data) {{:foo_message=>"bar"}} 
     Failure/Error: it {should contain_notify('foo').with_message(msg)}
       expected that the catalogue would contain Notify[foo] with message set to `"bar"` but it is set to `"broken"` in the catalogue
     # ./spec/classes/example_spec.rb:106:in `block (6 levels) in <top (required)>'

  4) canary::example rspec backend let(:hiera_data) {{"foo_message"=>"bar"}} 
     Failure/Error: it {should contain_notify('foo').with_message(msg)}
       expected that the catalogue would contain Notify[foo] with message set to `"bar"` but it is set to `"broken"` in the catalogue
     # ./spec/classes/example_spec.rb:106:in `block (6 levels) in <top (required)>'

  5) canary::example rspec backend let(:hiera_data) {{:foo_message=>"baz"}} 
     Failure/Error: it {should contain_notify('foo').with_message(msg)}
       expected that the catalogue would contain Notify[foo] with message set to `"baz"` but it is set to `"broken"` in the catalogue
     # ./spec/classes/example_spec.rb:106:in `block (6 levels) in <top (required)>'

  6) canary::example rspec backend let(:hiera_data) {{"foo_message"=>"baz"}} 
     Failure/Error: it {should contain_notify('foo').with_message(msg)}
       expected that the catalogue would contain Notify[foo] with message set to `"baz"` but it is set to `"broken"` in the catalogue
     # ./spec/classes/example_spec.rb:106:in `block (6 levels) in <top (required)>'

Finished in 0.31888 seconds
39 examples, 6 failures
```
