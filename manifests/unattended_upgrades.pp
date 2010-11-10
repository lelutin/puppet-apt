class apt::unattended_upgrades {
  package{'unattended-upgrades':
    ensure => present,
    require => undef,
  }

  config_file {
    "/etc/apt/apt.conf.d/50unattended-upgrades": 
    source  => ["puppet:///modules/site-apt/50unattended-upgrades", 
		"puppet:///modules/apt/50unattended-upgrades" ], 

    # err: Could not run Puppet configuration client: Could not find dependent Config_file[apt_config] for Config_file[/etc/apt/apt.conf.d/50unattended-upgrades] at /etc/puppet/modules/apt/manifests/unattended_upgrades.pp:14
      
    #before => Config_file[apt_config],
    require => Package['unattended-upgrades'],
  }
}
