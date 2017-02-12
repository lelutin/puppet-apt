class apt::cron::dist_upgrade (
  $cron_hours = '',
) {

  package { 'cron-apt':
    ensure => present;
  }

  case $cron_hours {
    '': {}
    default: {
      # cron-apt defaults to run every night at 4 o'clock
      # so we try not to run at the same time.
      cron { 'apt_cron_every_N_hours':
        command => 'test -x /usr/sbin/cron-apt && /usr/sbin/cron-apt',
        user    => root,
        hour    => $cron_hours,
        minute  => 10,
        require => Package['cron-apt'],
      }
    }
  }

  $action = "autoclean -y
dist-upgrade -y -o APT::Get::Show-Upgraded=true -o 'DPkg::Options::=--force-confold'
"

  file { '/etc/cron-apt/action.d/3-download':
    ensure => absent,
  }

  package { 'apt-listbugs':
    ensure => absent;
  }

  file { '/etc/cron-apt/action.d/4-dist-upgrade':
    content => $action,
    owner   => root,
    group   => 0,
    mode    => '0644',
    require => Package['cron-apt'];
  }

  file { '/etc/cron-apt/config.d/MAILON':
    content => "MAILON=upgrade\n",
    owner   => root,
    group   => 0,
    mode    => '0644',
    require => Package['cron-apt'];
  }
}
