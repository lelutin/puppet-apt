class apt::unattended_upgrades {
  package{'unattended-upgrades':
    ensure => present,
    require => undef,
  }

  apt_conf_snippet { "50unattended-upgrades":
    source  => ["puppet:///modules/site-apt/50unattended-upgrades",
		"puppet:///modules/apt/50unattended-upgrades" ],

    before => Concatenated_file[apt_config],
    require => Package['unattended-upgrades'],
  }
}
