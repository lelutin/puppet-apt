define apt::upgrade_package ($version = "") {

  include apt::update

  $version_suffix = $version ? {
    ''       => '',
    'latest' => '',
    default  => "=${version}",
  }

  package { ['apt-show-versions', 'dctrl-tools']:
    ensure => installed,
    require => undef,
  }

  exec { "aptitude -y install ${name}${version_suffix}":
    onlyif => [ "grep-status -F Status installed -a -P $name -q", "apt-show-versions -u $name | grep -q upgradeable" ],
    require => [
      Exec['apt_updated'],
      Package['apt-show-versions', 'dctrl-tools'],
    ],
  }

}
