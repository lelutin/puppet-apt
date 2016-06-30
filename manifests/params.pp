class apt::params () {
  $use_lts = false
  $use_volatile = false
  $use_backports = true
  $include_src = false
  $use_next_release = false
  $debian_url = 'http://httpredir.debian.org/debian/'
  $security_url = 'http://security.debian.org/'
  $ubuntu_url = 'http://archive.ubuntu.com/ubuntu'
  $lts_url = $debian_url
  $volatile_url = 'http://volatile.debian.org/debian-volatile/'
  case $::operatingsystem {
    'debian': {
      $repos = 'main contrib non-free'
    }
    'ubuntu': {
      $repos = 'main restricted universe multiverse'
    }
    default: {
      fail("Unsupported system '${::operatingsystem}'.")
    }
  }
  $custom_preferences = ''
  $custom_key_dir = false
}
