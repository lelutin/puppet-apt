class apt::dselect {
  # suppress annoying help texts of dselect
  line { dselect_expert:
      file => "/etc/dpkg/dselect.cfg",
      line => "expert",
      ensure => present,
  }

  package { dselect: ensure => installed }
}
