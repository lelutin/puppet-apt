source "https://rubygems.org"

def location_for(place, fake_version = nil)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end


group :test do
  gem "rake"
  gem "rspec", '< 3.2.0'
  gem "rspec-puppet"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem "mocha"
end

facterversion = ENV['GEM_FACTER_VERSION'] || ENV['FACTER_GEM_VERSION']
if facterversion
    gem 'facter', *location_for(facterversion)
else
    gem 'facter', :require => false
end

puppetversion = ENV['GEM_PUPPET_VERSION'] || ENV['PUPPET_GEM_VERSION']
if puppetversion
    gem 'puppet', *location_for(puppetversion)
else
    gem 'puppet', :require => false
end

