define apt::preferences_snippet(
  $package = $name,
  $ensure = 'present',
  $source = '',
  $release = '',
  $pin = '',
  $priority )
{

  if $custom_preferences == false {
    fail("Trying to define a preferences_snippet with \$custom_preferences set to false.")
  }

  if !$pin and !$release {
    fail("apt::preferences_snippet requires one of the 'pin' or 'release' argument to be set")
  }
  if $pin and $release {
    fail("apt::preferences_snippet requires either a 'pin' or 'release' argument, not both")
  }

  include apt::preferences

  concat::fragment{"apt_preference_${name}":
    ensure => $ensure,
    target => '/etc/apt/preferences',
  }

  # This should really work in the same manner as sources_list and apt_conf
  # snippets, but since the preferences.d directory cannot be used in Debian
  # lenny, we can't generalize without going into ugly special-casing.
  case $source {
    '': {
      case $release {
        '': {
          Concat::Fragment["apt_preference_${name}"]{
            content => template("apt/preferences_snippet.erb")
          }
        }
        default: {
          Concat::Fragment["apt_preference_${name}"]{
            content => template("apt/preferences_snippet_release.erb")
          }
        }
      }
    }
    default: {
      Concat::Fragment["apt_preference_${name}"]{
        source => $source
      }
    }
  }
}
