class apt::unattended_upgrades {

  package { 'unattended-upgrades':
    ensure  => present,
    require => Exec[refresh_apt]
  }

  apt_conf { '50unattended-upgrades':
    source  => [
                "puppet:///modules/site_apt/${::lsbdistid}/50unattended-upgrades.${::lsbdistcodename}",
                "puppet:///modules/site_apt/${::lsbdistid}/50unattended-upgrades",
                "puppet:///modules/apt/${::lsbdistid}/50unattended-upgrades.${::lsbdistcodename}",
                "puppet:///modules/apt/${::lsbdistid}/50unattended-upgrades" ],
    require => Package['unattended-upgrades'],
  }

  Apt_conf['50unattended-upgrades'] {
    notify => undef
  }
}
