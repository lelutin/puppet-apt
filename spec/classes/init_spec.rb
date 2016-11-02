require 'spec_helper'

describe 'apt', :type => :class do
  let :pre_condition do
    'class { "apt": }'
  end
  let(:facts) { {
    :lsbdistid => 'Debian',
    :osfamily => 'Debian',
    :operatingsystem => 'Debian',
    :debian_release  => 'jessie',
    :debian_codename => 'jessie',
    :lsbdistcodename => 'jessie',
    :virtual         => 'physical',
    :puppetversion   => Puppet.version, } }
  #it { is_expected.to compile.with_all_deps }
  it { is_expected.to compile }
end
