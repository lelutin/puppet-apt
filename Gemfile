source "https://rubygems.org"

group :development, :unit_tests do
  gem "rake"
  gem "rspec-puppet", "~> 2.1", :require => false
  gem "rspec-core", "3.1.7",    :require => false
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem "mocha"
end

group :system_tests do
  gem 'beaker'
  gem 'beaker-rspec'
  gem 'beaker_spec_helper'
  gem 'serverspec'
end

gem "puppet", ENV['PUPPET_VERSION'] || ENV['GEM_PUPPET_VERSION'] || ENV['PUPPET_GEM_VERSION'] || '~> 3.7.0'
gem "facter", ENV['FACTER_VERSION'] || ENV['GEM_FACTER_VERSION'] || ENV['FACTER_GEM_VERSION'] || '~> 2.2.0'

