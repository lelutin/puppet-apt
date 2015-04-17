class apt::unattended_upgrades (
  $config_content = undef,
  $mailonlyonerror = true,
  $mail_recipient = 'root',
  $blacklisted_packages = [],
) {

  package { 'unattended-upgrades':
    ensure  => present
  }

  $file_content = $config_content ? {
    undef   => template('apt/50unattended-upgrades.erb'),
    default => $config_content
  }

  apt_conf { '50unattended-upgrades':
    content => $file_content,
    require => Package['unattended-upgrades'],
  }
}
