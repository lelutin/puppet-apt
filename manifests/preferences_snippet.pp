define apt::preferences_snippet(
  $package = false,
  $ensure = 'present',
  $source = '',
  $release = '',
  $pin = '',
  $priority )
{

  $real_package = $package ? {
    false   => $name,
    default => $package,
  }

  if $custom_preferences == false {
    fail("Trying to define a preferences_snippet with \$custom_preferences set to false.")
  }

  if !$pin and !$release {
    fail("apt::preferences_snippet requires one of the 'pin' or 'release' argument to be set")
  }
  if $pin and $release {
    fail("apt::preferences_snippet requires either a 'pin' or 'release' argument, not both")
  }

  file { "/etc/apt/preferences.d/${name}":
    ensure => $ensure,
    owner => root, group => 0, mode => 0644;
  }

  # This should really work in the same manner as sources_list and apt_conf
  # snippets, but since the preferences.d directory cannot be used in Debian
  # lenny, we can't generalize without going into ugly special-casing.
  case $source {
    '': {
      case $release {
        '': {
          File["/etc/apt/preferences.d/${name}"]{
            content => template("apt/preferences_snippet.erb")
          }
        }
        default: {
          File["/etc/apt/preferences.d/${name}"]{
            content => template("apt/preferences_snippet_release.erb")
          }
        }
      }
    }
    default: {
      File["/etc/apt/preferences.d/${name}"]{
        source => $source
      }
    }
  }
}
