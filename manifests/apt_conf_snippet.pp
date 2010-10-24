define apt::apt_conf_snippet(
  $ensure = 'present',
  $source = '',
  $content = undef
){
  if $source == '' and $content == undef {
    fail("One of \$source or \$content must be specified for apt_conf_snippet ${name}")
  }
  if $source != '' and $content != undef {
    fail("Only one of \$source or \$content must specified for apt_conf_snippet ${name}")
  }

  if $source {
    file { "/etc/apt/apt.conf.d/${name}":
      ensure => $ensure,
      source => $source,
      notify => Exec["refresh_apt"],
      owner => root, group => 0, mode => 0600;
    }
  }
  else {
    file { "/etc/apt/apt.conf.d/${name}":
      ensure => $ensure,
      content => $content,
      notify => Exec["refresh_apt"],
      owner => root, group => 0, mode => 0600;
    }
  }
}
