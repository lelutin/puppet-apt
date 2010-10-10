class apt::cron::dist-upgrade inherits apt::cron::base {

  $action = "autoclean -y
dist-upgrade -y -o APT::Get::Show-Upgraded=true
"

  file { "/etc/cron-apt/action.d/3-download":
    ensure => absent,
  }

  config_file { "/etc/cron-apt/action.d/4-dist-upgrade":
    content => $action,
    require => Package[cron-apt]
  }

  config_file { "/etc/cron-apt/config.d/MAILON":
    content => "MAILON=upgrade\n",
    require => Package[cron-apt]
  }

}
