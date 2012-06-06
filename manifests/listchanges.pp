class apt::listchanges(
  $ensure_version = hiera('apt_listchanges_version','installed'),
  $config = hiera('apt_listchanges_config', "apt/${::operatingsystem}/listchanges_${::lsbdistcodename}.erb"),
  $frontend = hiera('apt_listchanges_frontend','mail'),
  $email = hiera('apt_listchanges_email','root'),
  $confirm = hiera('apt_listchanges_confirm','0'),
  $saveseen = hiera('pt_listchanges_saveseen','/var/lib/apt/listchanges.db'),
  $which = hiera('apt_listchanges_which','both')
){
  package { apt-listchanges: ensure => $ensure_version }
  
  file { "/etc/apt/listchanges.conf":
    content => template($apt::listchanges::config),
    mode => 0644, owner => root, group => root,
    require => Package["apt-listchanges"];
  }
}
