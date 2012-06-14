class apt::apticron(
  $ensure_version = 'installed',
  $config = "apt/${::operatingsystem}/apticron_${::lsbdistcodename}.erb",
  $email = 'root',
  $diff_only = '1',
  $listchanges_profile = 'apticron',
  $system = false,
  $ipaddressnum = false,
  $ipaddresses = false,
  $notifyholds = '0',
  $notifynew = '0',
  $customsubject = ''
) {

  package { apticron: ensure => $ensure_version }

  file { "/etc/apticron/apticron.conf":
    content => template($apt::apticron::config),
    mode => 0644, owner => root, group => root,
    require => Package["apticron"];  
  }
}
