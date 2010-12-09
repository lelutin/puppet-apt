class apt::listchanges {

  case $listchanges_version {
    '': { $listchanges_version = "present" }
  }

  case $listchanges_config {
    '': { $listchanges_config = "apt/${operatingsystem}/listchanges_${lsbrelease}.erb" }
  }

  case $listchanges_frontend {
    '' { $listchanges_frontend = "pager" }
  }

  case $listchanges_email {
    '': { $listchanges_email = "root" }
  }

  case $listchanges_confirm {
    '': { $listchanges_confirm = "0" }
  }

  case $listchanges_saveseen {
    '': { $listchanges_saveseen = "/var/lib/apt/listchanges.db" }
  }

  case $listchanges_which {
    '': { $listchanges_which = "both" }
  }

  package { apt-listchanges: ensure => $listchanges_ensure_version }
  
  file { "/etc/apt/listchanges.conf":
    content => template($listchanges_config),
    mode => 0644, owner => root, group => root,
    require => Package["apt-listchanges"];
  }
}
