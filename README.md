## Canary tests

This minimal module and rspec is a set of canary tests for 
[rspec-hiera-puppet](https://github.com/amfranz/rspec-hiera-puppet).

If [rspec-hiera-puppet](https://github.com/amfranz/rspec-hiera-puppet)
works, then the tests in this module should pass: [![Build Status](https://travis-ci.org/jumanjiman/rspec-hiera-puppet-canary.png?branch=master)](https://travis-ci.org/jumanjiman/rspec-hiera-puppet-canary)

[![Coverage Status](https://coveralls.io/repos/jumanjiman/rspec-hiera-puppet-canary/badge.png?branch=master)](https://coveralls.io/r/jumanjiman/rspec-hiera-puppet-canary?branch=master)

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

## Caveats

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

## Local testing

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

### Run the tests locally

Run the tests with:

    rake spec

