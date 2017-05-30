# Install a package with a preseed file to automatically answer some questions.
define apt::package (
  $ensure  = 'present',
  $use_seed = false,
  $seedfile_template = "site_apt/${::debian_codename}/${name}.seeds",
  $seedfile_content = '',
  $pin = '',
  $pin_priority = 1000
) {

  package { $name:
    ensure       => $ensure,
    responsefile => $seedfile,
  }

  if $use_seed {
    $seedfile = "/var/cache/local/preseeding/${name}.seeds"
    $real_seedfile_content = $seedfile_content ? {
      ''      => template ( $seedfile_template ),
      default => $seedfile_content,
    }

    file { $seedfile:
      content => $real_seedfile_content,
      mode    => '0600',
      owner   => 'root',
      group   => 0,
    }

    File[$seedfile] -> Package[$name]
  }

  if $pin {
    apt::preferences_snippet { $name:
      ensure   => $ensure,
      priority => $pin_priority,
      pin      => $pin,
    }

    Apt::Preferences_snippet[$name] -> Package[$name]
  }

}
