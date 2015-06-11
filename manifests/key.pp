define apt::key ($ensure => 'present', $source) {
  file {
    "/etc/apt/trusted.gpg.d/$name":
      source => $source,
      ensure => $ensure,
      notify => Exec['refresh_apt'],
  }
}
