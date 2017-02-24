class apt::preferences {

  if $::operatingsystem == "Debian" {

    file { '/etc/apt/preferences.d/stable':
     ensure  => present,
     alias   => 'apt_config',
     # only update together
     content => template('apt/Debian/stable.erb'),
     require => File['/etc/apt/sources.list'],
     owner   => root, group => 0, mode => '0644';
    }

    if $apt::use_volatile {

      file { '/etc/apt/preferences.d/volatile':
        ensure  => present,
        content => template('apt/Debian/volatile.erb'),
        require => File['/etc/apt/sources.list'],
        owner   => root, group => 0, mode => '0644';
      }
    }

    if $apt::use_lts {

      file { '/etc/apt/preferences.d/lts':
        ensure  => present,
        content => template('apt/Debian/lts.erb'),
        require => File['/etc/apt/sources.list'],
        owner   => root, group => 0, mode => '0644';
      }
    }

    if ($::debian_nextcodename) and ($::debian_nextcodename != "experimental") {

      file { '/etc/apt/preferences.d/nextcodename':
        ensure  => present,
        content => template('apt/Debian/nextcodename.erb'),
        require => File['/etc/apt/sources.list'],
        owner   => root, group => 0, mode => '0644';
      }
    }
  }

  elsif $::operatingsystem == "Ubuntu" {

    file { '/etc/apt/preferences':
     ensure  => present,
     alias   => 'apt_config',
     # only update together
     content => template("apt/Ubuntu/preferences_${apt::codename}.erb"),
     require => File['/etc/apt/sources.list'],
     owner   => root, group => 0, mode => '0644';
    }
  }
}
