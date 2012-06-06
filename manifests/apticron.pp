class apt::apticron(
  $ensure_version = hiera('apticron_ensure_version','installed'),
  $config = hiera('apticron_config',"apt/${::operatingsystem}/apticron_${::lsbdistcodename}.erb"),
  $email = hiera('apticron_email', 'root'),
  $diff_only = hiera('apticron_diff_only', '1'),
  $listchanges_profile = hiera('apticron_listchanges_profile','apticron'),
  $system = hiera('apticron_system',false),
  $ipaddressnum = hiera('apticron_ipaddressnum',false),
  $ipaddresses = hiera('apticron_ipaddresses', false),
  $notifyholds = hiera('apticron_notifyholds', '0'),
  $notifynew = hiera('apticron_notifynew', '0'),
  $customsubject = hiera('apticron_customsubject','')
) {

  package { apticron: ensure => $ensure_version }

  file { "/etc/apticron/apticron.conf":
    content => template($apt::apticron::config),
    mode => 0644, owner => root, group => root,
    require => Package["apticron"];  
  }
}
