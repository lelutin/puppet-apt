class apt::cron::download inherits apt::cron::base {

  $action = "autoclean -y
dist-upgrade -d -y -o APT::Get::Show-Upgraded=true
"

  file { "/etc/cron-apt/action.d/4-dist-upgrade":
    ensure => absent,
  }

  file {
    "/etc/cron-apt/action.d/3-download":
      content => $action,
      mode => 0644, owner => root, group => 0,
      require => Package[cron-apt];
    "/etc/cron-apt/config.d/MAILON":
      content => "MAILON=changes\n",
      mode => 0644, owner => root, group => 0,
      require => Package[cron-apt];
  }

}
