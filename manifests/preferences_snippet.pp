define apt::preferences_snippet(
  $ensure = 'present',
  $release,
  $priority
){
  file { "/var/lib/puppet/modules/apt/preferences/${name}":
    ensure => $ensure,
    content => "Package: ${name}
Pin: release a=${release}
Pin-Priority: ${priority}
",
    notify => Exec['concat_/var/lib/puppet/modules/apt/preferences'],
    owner => root, group => 0, mode => 0600;
  }
}
