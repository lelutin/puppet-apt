class apt::update {

  exec { 'update_apt':
    command => '/usr/bin/apt-get update && /usr/bin/apt-get autoclean',
    require => [ File['/etc/apt/apt.conf.d', '/etc/apt/preferences' ],
                 File['/etc/apt/sources.list'] ],
    loglevel => info,
    # Another Semaphor for all packages to reference
    alias => "apt_updated"
  }

}
