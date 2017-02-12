class apt::reboot_required_notify::wheezy ($ensure = present) {

  # On Wheezy and older, this package installs the script that created
  # /var/run/reboot-required*.
  # This script (/usr/share/update-notifier/notify-reboot-required) is
  # triggered e.g. by kernel packages.
  package { 'update-notifier-common':
    ensure => $ensure,
  }

  # cron-apt defaults to run every night at 4 o'clock
  # plus some random time <1h.
  # so we check if a reboot is required a bit later.
  cron { 'apt_reboot_required_notify':
    ensure  => $ensure,
    command => 'if [ -f /var/run/reboot-required ]; then echo "Reboot required\n" ; cat /var/run/reboot-required.pkgs ; fi',
    user    => root,
    hour    => 5,
    minute  => 20,
    require => Package['update-notifier-common'],
  }
}
