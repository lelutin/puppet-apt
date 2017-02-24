# Install a package with a preseed file to automatically answer some questions.
define apt::package (
  $ensure  = 'present',
  $seedfile_content = '',
  $pin = '',
  $pin_priority = 1000
) {

  $seedfile = "/var/cache/local/preseeding/${name}.seeds"
  $real_seedfile_content = $seedfile_content ? {
    ''      => template ( "site_apt/${::debian_codename}/${name}.seeds" ),
    default => $seedfile_content,
  }

  file { $seedfile:
    content => $real_seedfile_content,
    mode    => '0600',
    owner   => 'root',
    group   => 0,
  }

  if $pin {
    apt::preferences_snippet { $name:
      ensure   => $ensure,
      priority => $pin_priority,
      pin      => $pin,
    }
  }

  package { $name:
    ensure       => $ensure,
    responsefile => $seedfile,
    require      => [File[$seedfile], Apt::Preferences_snippet[$name]],
  }
}
