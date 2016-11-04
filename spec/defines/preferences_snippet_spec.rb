require 'spec_helper'
describe 'apt::preferences_snippet', :type => :define do
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
  let :title do
    'test'
  end

  describe "when creating a preferences_snippet" do
    let :default_params do
      {
        :ensure  => 'present',
        :release => "jessie-backports",
        :priority => '999'
      }
    end
    let :params do
      default_params
    end
    let :filename do
      "/etc/apt/preferences.d/test"
    end

    it { is_expected.to contain_file(filename).with({
          'ensure'    => 'present',
          'content'   => /Package: test\nPin: release a=jessie-backports\nPin-Priority: 999/,
          'owner'     => 'root',
          'group'     => '0',
          'mode'      => '0644',
        })
      }

  end

  describe "when using both pin and release parameters" do
    let :default_params do
      {
        :ensure  => 'present',
        :priority => '999',
        :release => "jessie-backports",
        :pin     => '1.0'
      }
    end
    let :params do
      default_params
    end
    let :filename do
      "/etc/apt/preferences.d/test"
    end

    it 'fails' do
      expect { subject.call } .to raise_error(Puppet::Error, /apt::preferences_snippet requires either a 'pin' or 'release' argument, not both/)
    end
  end

end
