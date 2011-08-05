class apt::preferences {

  concat::fragment{"apt_preferences_header":
    content => $custom_preferences ? {
      '' => $operatingsystem ? {
        'debian' => template("apt/${operatingsystem}/preferences_${codename}.erb"),
        'ubuntu' => template("apt/${operatingsystem}/preferences_${codename}.erb"),
      },
      default => $custom_preferences
    },
    order => 00,
    target => '/etc/apt/preferences',
  }

  concat{'/etc/apt/preferences':
    alias => apt_config,
    # only update together
    require => File["/etc/apt/sources.list"],
    owner => root, group => 0, mode => 0644;
  }

}
