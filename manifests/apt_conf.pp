define apt::apt_conf(
  $ensure = 'present',
  $source = '',
  $content = undef )
{

  if $source == '' and $content == undef {
    fail("One of \$source or \$content must be specified for apt_conf ${name}")
  }

  if $source != '' and $content != undef {
    fail("Only one of \$source or \$content must specified for apt_conf ${name}")
  }

  include apt::dot_d_directories

  file { "/etc/apt/apt.conf.d/${name}":
    ensure => $ensure,
    notify => Exec["refresh_apt"],
    owner => root, group => 0, mode => 0644;
  }

  if $source {
    File["/etc/apt/apt.conf.d/${name}"] {
      source => $source,
    }
  }
  else {
    File["/etc/apt/apt.conf.d/${name}"] {
      content => $content,
    }
  }
}
