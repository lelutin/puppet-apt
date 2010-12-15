class apt::listchanges {

  case $apt_listchanges_version {
    '': { $apt_listchanges_version = "present" }
  }

  case $apt_listchanges_config {
    '': { $apt_listchanges_config = "apt/${operatingsystem}/listchanges_${lsbdistcodename}.erb" }
  }

  case $apt_listchanges_frontend {
    '': { $apt_listchanges_frontend = "mail" }
  }

  case $apt_listchanges_email {
    '': { $apt_listchanges_email = "root" }
  }

  case $apt_listchanges_confirm {
    '': { $apt_listchanges_confirm = "0" }
  }

  case $apt_listchanges_saveseen {
    '': { $apt_listchanges_saveseen = "/var/lib/apt/listchanges.db" }
  }

  case $apt_listchanges_which {
    '': { $apt_listchanges_which = "both" }
  }

  package { apt-listchanges: ensure => $apt_listchanges_ensure_version }
  
  file { "/etc/apt/listchanges.conf":
    content => template($apt_listchanges_config),
    mode => 0644, owner => root, group => root,
    require => Package["apt-listchanges"];
  }
}
