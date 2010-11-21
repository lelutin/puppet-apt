define apt::preferences_snippet(
  $ensure = 'present',
  $source = '',
  $release,
  $priority
){
  include apt::preferences

  file { "${apt::preferences::apt_preferences_dir}/${name}":
    ensure => $ensure,
    #TODO this template is somewhat limited
    notify => Exec["concat_${apt::preferences::apt_preferences_dir}"],
    owner => root, group => 0, mode => 0600;
  }

  # This should really work in the same manner as sources_list and apt_conf
  # snippets, but since the preferences.d directory cannot be used in Debian
  # lenny, we can't generalize without going into ugly special-casing.
  case $source {
    '' =>
      File["${apt::preferences::apt_preferences_dir/${name}"] {
        content => template("apt/preferences_snippet.erb")
      },
    default =>
      File["${apt::preferences::apt_preferences_dir/${name}"] {
        source => $source
      }
  }
}
