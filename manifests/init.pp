# apt.pp - common components and defaults for handling apt
# Copyright (C) 2008 Micah Anerson <micah@riseup.net>
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class apt {

  package { apt:
    ensure => installed,
    require => undef,
  }

  include lsb
  config_file {
    # include main, security and backports
    # additional sources should be included via the apt::sources_list define
    "/etc/apt/sources.list":
      content => $custom_sources_list ? {
        '' => template( "apt/$operatingsystem/sources.list.erb"),
        default => $custom_sources_list
      },
      require => Package['lsb'];
  }

  # 01autoremove already present by default
  apt_conf { "02show_upgraded":
    source => ["puppet:///modules/site-apt/${fqdn}/02show_upgraded",
               "puppet:///modules/site-apt/02show_upgraded",
               "puppet:///modules/apt/02show_upgraded"]
  }

  apt_conf { "03clean":
    source => ["puppet:///modules/site-apt/${fqdn}/03clean",
               "puppet:///modules/site-apt/03clean",
               "puppet:///modules/apt/03clean"]
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

  include common::moduledir
  $apt_base_dir = "${common::moduledir::module_dir_path}/apt"
  modules_dir { apt: }

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
