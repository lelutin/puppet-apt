# apt.pp - common components and defaults for handling apt
# Copyright (C) 2008 Micah Anerson <micah@riseup.net>
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class apt {

  import "custom_sources.pp"

  # See README
  $real_apt_clean = $apt_clean ? {
    '' => 'auto',
    default => $apt_clean,
  }

  $use_volatile = $apt_volatile_enabled ? {
    ''      => false,
    default => $apt_volatile_enabled,
  }

  $include_src = $apt_include_src ? {
    ''      => false,
    default => $apt_include_src,
  }

  $use_next_release = $apt_use_next_release ? {
    ''      => false,
    default => $apt_use_next_release,
  }

  $debian_url = $apt_debian_url ? {
    ''      => 'http://ftp.debian.org/debian/',
    default => "${apt_debian_url}",
  }
  $security_url = $apt_security_url ? {
    ''      => 'http://security.debian.org/',
    default => "${apt_security_url}",
  }
  $backports_url = $apt_backports_url ? {
    ''      => 'http://backports.debian.org/debian-backports/',
    default => "${apt_backports_url}",
  }
  $volatile_url = $apt_volatile_url ? {
    ''      => 'http://volatile.debian.org/debian-volatile/',
    default => "${apt_volatile_url}",
  }
  $ubuntu_url = $apt_ubuntu_url ? {
    ''      => 'http://archive.ubuntu.com/ubuntu',
    default => "${apt_ubuntu_url}",
  }
  case $operatingsystem {
    'debian': {
      $repos = $apt_repos ? {
        ''      => 'main contrib non-free',
        default => "${apt_repos}",
      }
    }
    'ubuntu': {
      $repos = $apt_repos ? {
        ''      => 'main restricted universe multiverse',
        default => "${apt_repos}",
      }
    }
  }

  package { apt:
    ensure => installed,
    require => undef,
  }

  # init $release, $next_release, $codename, $next_codename
  case $lsbdistcodename {
    '': {
      include lsb
      $codename = $lsbdistcodename
      $release = $lsbdistrelease
    }
    default: {
      $codename = $lsbdistcodename
      $release = debian_release($codename)
    }
  }
  $next_codename = debian_nextcodename($codename)
  $next_release = debian_nextrelease($release)

  case $custom_sources_list {
    '': {
      include apt::default_sources_list
    }
    default: {
      config_file { "/etc/apt/sources.list":
        content => $custom_sources_list,
      }
    }
  }

  case $custom_preferences {
    '': {
      include apt::default_preferences
    }
    default: {
      config_file { "/etc/apt/preferences":
        content => $custom_preferences,
        alias => "apt_config",
        require => File["/etc/apt/sources.list"];
      }
    }
  }

  config_file { '/etc/apt/apt.conf.d/99from_puppet': }
  # little default settings which keep the system sane
  append_if_no_such_line { 'apt-get-show-upgraded':
    file    => "/etc/apt/apt.conf.d/99from_puppet",
    line    => "APT::Get::Show-Upgraded true;",
    before  => Config_file[apt_config],
    require => Config_file['/etc/apt/apt.conf.d/99from_puppet'],
  }
  append_if_no_such_line { 'dselect-clean':
    file    => "/etc/apt/apt.conf.d/99from_puppet",
    line    => "DSelect::Clean ${real_apt_clean};",
    before  => Config_file[apt_config],
    require => Config_file['/etc/apt/apt.conf.d/99from_puppet'],
  }
  # backward compatibility: upgrade from previous versions of this module.
  file {
    "/etc/apt/apt.conf.d/from_puppet":
      ensure  => 'absent',
      require => [ Append_if_no_such_line['apt-get-show-upgraded'],
                   Append_if_no_such_line['dselect-clean']
                 ],
  }

  if $apt_unattended_upgrades {
    include apt::unattended_upgrades
  }

  include common::moduledir
  $apt_base_dir = "${common::moduledir::module_dir_path}/apt"
  modules_dir { apt: }
  # watch apt.conf.d
  file { "/etc/apt/apt.conf.d": ensure => directory, checksum => mtime; }

  exec {
    # "&& sleep 1" is workaround for older(?) clients
    'refresh_apt':
      command => '/usr/bin/apt-get update && sleep 1',
      refreshonly => true,
      subscribe => [ File["/etc/apt/apt.conf.d"],
                     Config_file["/etc/apt/preferences", "/etc/apt/sources.list", "apt_config"] ];
    'update_apt':
      command => '/usr/bin/apt-get update && /usr/bin/apt-get autoclean',
      require => [ Config_file["/etc/apt/preferences", "/etc/apt/sources.list", "apt_config"] ],
      loglevel => info,
      # Another Semaphor for all packages to reference
      alias => "apt_updated";
  }

  ## This package should really always be current
  package { "debian-archive-keyring": ensure => latest }
  # backports uses the normal archive key now
  package { "debian-backports-keyring": ensure => absent }

  if $custom_key_dir {
    file { "${apt_base_dir}/keys.d":
      source => "$custom_key_dir",
      recurse => true,
      mode => 0755, owner => root, group => root,
    }
    exec { "find ${apt_base_dir}/keys.d -type f -exec apt-key add '{}' \\; && apt-get update":
      alias => "custom_keys",
      subscribe => File["${apt_base_dir}/keys.d"],
      refreshonly => true,
      before => Config_file[apt_config];
    }
  }

  # workaround for preseeded_package component
  file { [ "/var/cache", "/var/cache/local", "/var/cache/local/preseeding" ]: ensure => directory }
}
