require 'spec_helper'
describe 'apt::apt_conf', :type => :define do
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
    'norecommends'
  end

  describe "when creating an apt_conf snippet" do
    let :default_params do
      {
        :ensure  => 'present',
        :content  => "Apt::Install-Recommends 0;\nApt::AutoRemove::InstallRecommends 1;\n"
      }
    end
    let :params do
      default_params
    end
    let :filename do
      "/etc/apt/apt.conf.d/norecommends"
    end

    it { is_expected.to contain_file(filename).with({
          'ensure'    => 'present',
          'content'   => /Apt::Install-Recommends 0;\nApt::AutoRemove::InstallRecommends 1;/,
          'owner'     => 'root',
          # default to '0', not 'root'
          #'group'     => 'root',
          'mode'      => '0644',
        })
      }

  end

  describe "when creating a preference without content" do
    let :params do
      {
        :ensure   => 'absent',
      }
    end

    it 'fails' do
      expect { subject.call } .to raise_error(Puppet::Error, /One of \$source or \$content must be specified for apt_conf norecommends/)
    end
  end

  describe "when removing an apt preference" do
    let :params do
      {
        :ensure   => 'absent',
        :content  => "Apt::Install-Recommends 0;\nApt::AutoRemove::InstallRecommends 1;\n",
      }
    end

    let :filename do
      "/etc/apt/apt.conf.d/norecommends"
    end

    it { is_expected.to contain_file(filename).with({
        'ensure'    => 'absent',
      })
    }
  end
end
