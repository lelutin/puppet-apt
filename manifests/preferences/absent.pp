class apt::preferences::absent {

  file { '/etc/apt/preferences':
    alias => 'apt_config',
    ensure => absent,
  }
}
