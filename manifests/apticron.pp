class apt::apticron (
  $ensure_version      = 'present',
  $config              = "apt/${::operatingsystem}/apticron.erb",
  $email               = 'root',
  $diff_only           = '1',
  $listchanges_profile = 'apticron',
  $system              = false,
  $ipaddressnum        = false,
  $ipaddresses         = false,
  $notifyholds         = '0',
  $notifynew           = '0',
  $customsubject       = '',
) {

  package { 'apticron':
    ensure => $ensure_version;
  }

  file { '/etc/apticron/apticron.conf':
    content => template($apt::apticron::config),
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['apticron'];
  }
}
