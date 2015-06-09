class apt::params () {
  $codename = $::lsbdistcodename
  $use_lts = false
  $use_volatile = false
  $use_backports = true
  $include_src = false
  $use_next_release = false
  $debian_url = 'http://httpredir.debian.org/debian/'
  $security_url = 'http://security.debian.org/'
  $backports_url = $::lsbdistcodename ? {
    'squeeze'  => 'http://backports.debian.org/debian-backports/',
    default => $debian_url
  }
  $lts_url = $debian_url
  $volatile_url = 'http://volatile.debian.org/debian-volatile/'
  $ubuntu_url = 'http://archive.ubuntu.com/ubuntu'
  $repos = 'auto'
  $custom_preferences = ''
  $disable_update = false
  $custom_key_dir = false
}
