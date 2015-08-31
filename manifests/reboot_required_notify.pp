class apt::reboot_required_notify {

  $jessie_or_newer = $::operatingsystemmajrelease ? {
    5       => false,
    6       => false,
    7       => false,
    default => true,
  }

  if $jessie_or_newer {
    class { 'apt::reboot_required_notify::jessie': }
    # Clean up systems that were upgraded from Wheezy or earlier:
    class { 'apt::reboot_required_notify::wheezy': ensure => absent }
  } else {
    class { 'apt::reboot_required_notify::wheezy': }
  }

}
