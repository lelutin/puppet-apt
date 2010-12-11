class apt::apticron {

  case $apticron_ensure_version {
    '': { $apticron_ensure_version = "present" }
  }

  case $apticron_config {
    '': { $apticron_config = "apt/${operatingsystem}/apticron_${lsbdistcodename}.erb" }
  }

  case $apticron_email {
    '': { $apticron_email = "root" }
  }

  case $apticron_diff_only {
    '': { $apticron_diff_only = "1" }
  }

  case $apticron_listchanges_profile {
    '': { $apticron_listchanges_profile = "apticron" }
  }

  case $apticron_system {
    '': { $apticron_system = false }
  }

  case $apticron_ipaddressnum {
    '': { $apticron_ipaddressnum = false }
  }

  case $apticron_ipaddresses {
    '': { $apticron_ipaddresses = false }
  }

  case $apticron_notifyholds {
    '': { $apticron_notifyholds = "0" }
  }

  case $apticron_notifynew {
    '': { $apticron_notifynew = "0" }
  }

  case $apticron_customsubject {
    '': { $apticron_customsubject = "" }
  }
  
  package { apticron: ensure => $apticron_ensure_version }

  file { "/etc/apticron/apticron.conf":
    content => template($apticron_config),
    mode => 0644, owner => root, group => root,
    require => Package["apticron"];  
  }
}
