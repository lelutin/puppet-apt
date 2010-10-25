class apt::preferences::absent {
  file {'/etc/apt/preferences':
    ensure => absent,
  }
}
