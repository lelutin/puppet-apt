class apt::default_preferences {
  case $operatingsystem {
    'debian': {
      config_file {
        "/etc/apt/preferences":
          content => template("apt/${operatingsystem}/preferences_${codename}.erb"),
          # use File[apt_config] to reference a completed configuration
          # See "The Puppet Semaphor" 2007-06-25 on the puppet-users ML
          alias => apt_config,
          # only update together
          require => File["/etc/apt/sources.list"];
      }
    }
    'ubuntu': {
      notice('There is no support for default Ubuntu APT preferences')
    }
  }
}
