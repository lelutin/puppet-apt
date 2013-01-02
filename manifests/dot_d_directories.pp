class apt::dot_d_directories {

  # watch .d directories and ensure they are present
  file {
    '/etc/apt/apt.conf.d':
      ensure   => directory,
      checksum => mtime,
      notify   => Exec['refresh_apt'];
    '/etc/apt/sources.list.d':
      ensure   => directory,
      checksum => mtime,
      notify   => Exec['refresh_apt'];
  }

  exec {
    # "&& sleep 1" is workaround for older(?) clients
    'refresh_apt':
      command     => '/usr/bin/apt-get update && sleep 1',
      refreshonly => true,
  }

}
