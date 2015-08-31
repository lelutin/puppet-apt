class apt::reboot_required_notify::jessie ($ensure = present) {

  # On Jessie and newer, this package installs the script that created
  # /var/run/reboot-required*.
  # This script (/usr/share/update-notifier/notify-reboot-required) is
  # triggered e.g. by kernel packages.
  # This package also sends a daily email to the administrator when a system
  # reboot is required, e.g. due to a kernel update.
  package { 'reboot-notifier':
    ensure => $ensure,
  }
  
}
