define apt::preferences_snippet (
  $priority = undef,
  $package  = false,
  $ensure   = 'present',
  $source   = undef,
  $release  = undef,
  $pin      = undef,
) {

  $real_package = $package ? {
    false   => $name,
    default => $package,
  }

  if $ensure == 'present' {

    if $priority == undef {
      fail("apt::preferences_snippet requires the 'priority' argument to be set")
    }

    if !$pin and !$release {
      fail("apt::preferences_snippet requires one of the 'pin' or 'release' argument to be set")
    }
    if $pin and $release {
      fail("apt::preferences_snippet requires either a 'pin' or 'release' argument, not both")
    }
  }

  file { "/etc/apt/preferences.d/${name}":
    ensure => $ensure,
    owner  => root, group => 0, mode => '0644',
    before => Exec['update_apt'];
  }

  case $source {
    undef: {
      case $release {
        undef: {
          File["/etc/apt/preferences.d/${name}"]{
            content => template('apt/preferences_snippet.erb'),
          }
        }
        default: {
          File["/etc/apt/preferences.d/${name}"]{
            content => template('apt/preferences_snippet_release.erb'),
          }
        }
      }
    }
    default: {
      File["/etc/apt/preferences.d/${name}"]{
        source => $source,
      }
    }
  }
}
