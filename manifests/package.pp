# Install a package with a preseed file to automatically answer some questions.
define apt::package (
  $ensure  = 'present',
  $seedfile_content = '',
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

  package { $name:
    ensure       => $ensure,
    responsefile => $seedfile,
    require      => File[$seedfile],
  }
}
