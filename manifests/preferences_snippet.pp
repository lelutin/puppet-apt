define apt::preferences_snippet(
  $ensure = 'present',
  $release,
  $priority
){
  include apt::preferences
  file { "${apt::preferences::apt_preferences_dir}/${name}":
    ensure => $ensure,
    content => "Package: ${name}
Pin: release a=${release}
Pin-Priority: ${priority}
",
    notify => Exec["concat_${apt::preferences::apt_preferences_dir}"],
    owner => root, group => 0, mode => 0600;
  }
}
