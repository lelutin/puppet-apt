class apt::preferences::absent {
  include common::moduledir
  $apt_preferences_dir = "${common::moduledir::module_dir_path}/apt/preferences"
  concatenated_file{'/etc/apt/preferences':
    dir => $apt_preferences_dir,
    ensure => absent,
  }
}
