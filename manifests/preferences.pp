class apt::preferences {

  if ($apt::manage_preferences == true) and ($apt::custom_preferences != undef) {

    file { '/etc/apt/preferences.d/custom':
      ensure  => present,
      alias   => 'apt_config',
      # only update together
      content => $custom_preferences,
      require => File['/etc/apt/sources.list'],
      owner   => root, group => 0, mode => '0644';
    }
  }

  elsif $apt::manage_preferences == true {

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

  elsif $apt::manage_preferences == false {

    file {
      [ '/etc/apt/preferences.d/custom',
        '/etc/apt/preferences.d/stable',
        '/etc/apt/preferences.d/volatile',
        '/etc/apt/preferences.d/lts',
        '/etc/apt/preferences.d/nextcodename']:
          ensure => absent;
    }
  }
}
