class apt::dselect {

  # suppress annoying help texts of dselect
  append_if_no_such_line { dselect_expert:
      file => "/etc/dpkg/dselect.cfg",
      line => "expert",
  }

  package { dselect: ensure => installed }
}
