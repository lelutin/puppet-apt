class apt::preferences {

  include common::moduledir
  $apt_preferences_dir = "${common::moduledir::module_dir_path}/apt/preferences"
  module_dir{'apt/preferences': }
  file{"${apt_preferences_dir}_header":
    content => 'Package: *
Pin: release a=unstable
Pin-Priority: 1

Package: *
Pin: release a=testing
Pin-Priority: 2
',
  }

  concatenated_file{'/etc/apt/preferences':
    dir => $apt_preferences_dir,
    header => "${apt_preferences_dir}_header",
    # use Concatenated_file[apt_config] to reference a completed configuration
    # See "The Puppet Semaphor" 2007-06-25 on the puppet-users ML
    alias => apt_config,
    # only update together
    require => File["/etc/apt/sources.list"];
  }

  config_file {
    # little default settings which keep the system sane
    "/etc/apt/apt.conf.d/from_puppet":
      content => "APT::Get::Show-Upgraded true;\nDSelect::Clean $real_apt_clean;\n",
      before => Concatenated_file[apt_config];
  }
}
