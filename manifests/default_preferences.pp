class apt::default_preferences {
  config_file {
    # this just pins unstable and testing to very low values
    "/etc/apt/preferences":
      content => template("apt/preferences.erb"),
      # use File[apt_config] to reference a completed configuration
      # See "The Puppet Semaphor" 2007-06-25 on the puppet-users ML
      alias => apt_config,
      # only update together
      require => File["/etc/apt/sources.list"];
  }
}
