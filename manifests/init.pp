# apt.pp - common components and defaults for handling apt
# Copyright (C) 2008 Micah Anerson <micah@riseup.net>
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class apt {

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

  include apt::preferences

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
      subscribe => [ File["/etc/apt/sources.list"],
                     File["/etc/apt/apt.conf.d"],
                     Concatenated_file[apt_config] ];
      'update_apt':
        command => '/usr/bin/apt-get update && /usr/bin/apt-get autoclean',
        require => [ File["/etc/apt/sources.list"],
                     File["/etc/apt/preferences"], Concatenated_file[apt_config] ],
        loglevel => info,
        # Another Semaphor for all packages to reference
        alias => apt_updated;
  }

  ## This package should really always be current
  package { "debian-archive-keyring": ensure => latest }
        
  case $lsbdistcodename {
    etch: {
      package { "debian-backports-keyring": ensure => latest }
                
      # This key was downloaded from
      # http://backports.org/debian/archive.key
      # and is needed to bootstrap the backports trustpath
      file { "${apt_base_dir}/backports.org.key":
        source => "puppet:///modules/apt/backports.org.key",
        mode => 0444, owner => root, group => root,
      }
      exec { "/usr/bin/apt-key add ${apt_base_dir}/backports.org.key && apt-get update":
        alias => "backports_key",
        refreshonly => true,
        subscribe => File["${apt_base_dir}/backports.org.key"],
        before => [ Concatenated_file[apt_config], Package["debian-backports-keyring"] ]
      }
    }
    lenny: {
      package { "debian-backports-keyring": ensure => latest }

      # This key was downloaded from
      # http://backports.org/debian/archive.key
      # and is needed to bootstrap the backports trustpath
      file { "${apt_base_dir}/backports.org.key":
        source => "puppet:///modules/apt/backports.org.key",
        mode => 0444, owner => root, group => root,
      }
      exec { "/usr/bin/apt-key add ${apt_base_dir}/backports.org.key && apt-get update":
        alias => "backports_key",
        refreshonly => true,
        subscribe => File["${apt_base_dir}/backports.org.key"],
        before => [ Concatenated_file[apt_config], Package["debian-backports-keyring"] ]
      }
    }
  }

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
