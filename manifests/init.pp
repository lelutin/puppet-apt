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

  package { apt:
    ensure => installed,
    require => undef,
  }

  case $custom_sources_list {
    '': {
      include apt::default_sources_list
    }
    default: {
      include lsb
      config_file { "/etc/apt/sources.list":
        content => $custom_sources_list,
        require => Package['lsb'];
      }
    }
  }

  config_file {
    # little default settings which keep the system sane
    "/etc/apt/apt.conf.d/from_puppet":
      content => "APT::Get::Show-Upgraded true;\nDSelect::Clean $real_apt_clean;\n",
      before => Concatenated_file['/etc/apt/preferences'];
  }

  case $custom_preferences {
    false: {
      include apt::preferences::absent
    }
    default: {
      include apt::preferences
    }
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
      subscribe => File['/etc/apt/sources.list',
                        '/etc/apt/apt.conf.d',
                        '/etc/apt/preferences'];
      'update_apt':
        command => '/usr/bin/apt-get update && /usr/bin/apt-get autoclean',
        require => File['/etc/apt/sources.list',
                        '/etc/apt/preferences'],
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
      before => Concatenated_file[apt_config];
    }
  }

  # workaround for preseeded_package component
  file { [ "/var/cache", "/var/cache/local", "/var/cache/local/preseeding" ]: ensure => directory }
}     
