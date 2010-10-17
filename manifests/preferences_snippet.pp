define apt::preferences_snippet(
  $ensure => 'present',
  $content
){
  file { "/var/lib/puppet/modules/apt/preferences/${name}":
    ensure => $ensure,
    content => "${content}\n",
    notify => Exec['concat_/var/lib/puppet/modules/apt/preferences'],
    owner => root, group => 0, mode => 0600;
  }
}
