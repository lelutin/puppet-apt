class apt::dselect {

  # suppress annoying help texts of dselect
  line { 'dselect_expert':
      file => '/etc/dpkg/dselect.cfg',
      line => 'expert',
  }

  package { 'dselect': ensure => installed }
}
