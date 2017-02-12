class apt::reboot_required_notify {

  if versioncmp($::operatingsystemmajrelease, 8) >= 0 {
    class { 'apt::reboot_required_notify::jessie': }
    # Clean up systems that were upgraded from Wheezy or earlier:
    class { 'apt::reboot_required_notify::wheezy': ensure => absent }
  } else {
    class { 'apt::reboot_required_notify::wheezy': }
  }
}
