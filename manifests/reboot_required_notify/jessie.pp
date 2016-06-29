class apt::reboot_required_notify::jessie ($ensure = present) {

  if $::operatingsystemmajrelease == 8 and ! $::apt::use_backports {
    fail('apt::reboot_required_notify requires $apt::use_backports on Jessie')
  }

  $pinning_ensure = $::operatingsystemmajrelease ? {
    8       => present,
    default => absent,
  }
  apt::preferences_snippet { 'reboot-notifier':
    ensure   => $pinning_ensure,
    pin      => 'release o=Debian Backports,a=jessie-backports',
    priority => 991,
  }

  # On Jessie and newer, this package installs the script that created
  # /var/run/reboot-required*.
  # This script (/usr/share/update-notifier/notify-reboot-required) is
  # triggered e.g. by kernel packages.
  # This package also sends a daily email to the administrator when a system
  # reboot is required, e.g. due to a kernel update.
  package { 'reboot-notifier':
    ensure  => $ensure,
    require => Apt::Preferences_snippet['reboot-notifier'],
  }

}
