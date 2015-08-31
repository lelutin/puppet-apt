define apt::key ($source, $ensure = 'present') {
  file {
    "/etc/apt/trusted.gpg.d/${name}":
      ensure => $ensure,
      source => $source,
      notify => Exec['refresh_apt'],
  }
}
