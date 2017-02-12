class apt::install {

  package { 'apt':
    ensure => present;
  }

  # This package should really always be current
  package { 'debian-archive-keyring':
    ensure => latest;
  }
}
