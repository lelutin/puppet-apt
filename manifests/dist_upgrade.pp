class apt::dist_upgrade (
  $timeout = 300,
) {

  exec { 'apt_dist-upgrade':
    command     => '/usr/bin/apt-get -q -y -o \'DPkg::Options::=--force-confold\' dist-upgrade',
    refreshonly => true,
    timeout     => $timeout,
    before      => Exec['update_apt'];
  }
}
