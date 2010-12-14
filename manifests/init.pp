# apt.pp - common components and defaults for handling apt
# Copyright (C) 2008 Micah Anerson <micah@riseup.net>
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class apt {

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
    ''      => 'http://cdn.debian.net/debian/',
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

  include lsb

  # init $release, $next_release, $codename, $next_codename, $release_version
  case $lsbdistcodename {
    '': {
      $codename = $lsbdistcodename
      $release = $lsbdistrelease
    }
    default: {
      $codename = $lsbdistcodename
      $release = debian_release($codename)
    }
  }
  $release_version = debian_release_version($codename)
  $next_codename = debian_nextcodename($codename)
  $next_release = debian_nextrelease($release)

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

  apt_conf { "02show_upgraded":
    source => [ "puppet:///modules/site-apt/${fqdn}/02show_upgraded",
                "puppet:///modules/site-apt/02show_upgraded",
                "puppet:///modules/apt/02show_upgraded" ]
  }

  if ( $virtual == "vserver" ) {
    apt_conf { "03clean_vserver":
      source => [ "puppet:///modules/site-apt/${fqdn}/03clean_vserver",
                  "puppet:///modules/site-apt/03clean_vserver",
                  "puppet:///modules/apt/03clean_vserver" ],
      alias => "03clean";
    }
  }
  else {
    apt_conf { "03clean":
      source => [ "puppet:///modules/site-apt/${fqdn}/03clean",
                  "puppet:///modules/site-apt/03clean",
                  "puppet:///modules/apt/03clean" ]
    }
  }
    
  case $custom_preferences {
    false: {
      include apt::preferences::absent
    }
    default: {
      # When squeeze becomes the stable branch, transform this file's header
      # into a preferences.d file
      include apt::preferences
    }
  }

  # backward compatibility: upgrade from previous versions of this module.
  file {
    [ "/etc/apt/apt.conf.d/from_puppet", "/etc/apt/apt.conf.d/99from_puppet" ]:
      ensure  => 'absent',
      require => [ Apt_conf['02show_upgraded'], Apt_conf['03clean'] ];
  }

  # watch .d directories and ensure they are present
  file { "/etc/apt/apt.conf.d": ensure => directory, checksum => mtime; }
  file { "/etc/apt/sources.list.d":
    ensure => directory,
    checksum => mtime,
    notify => Exec['refresh_apt'],
  }

  exec {
    # "&& sleep 1" is workaround for older(?) clients
    'refresh_apt':
      command => '/usr/bin/apt-get update && sleep 1',
      refreshonly => true,
      subscribe => [ File['/etc/apt/apt.conf.d'], Config_file['/etc/apt/sources.list'] ];

    'update_apt':
      command => '/usr/bin/apt-get update && /usr/bin/apt-get autoclean',
      refreshonly => true,
      require => [ File['/etc/apt/apt.conf.d', '/etc/apt/preferences' ],
                   Config_file['/etc/apt/sources.list'] ],
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
    exec { "custom_keys":
      command => "find ${apt_base_dir}/keys.d -type f -exec apt-key add '{}' \\; && /usr/bin/apt-get update",
      subscribe => File["${apt_base_dir}/keys.d"],
      refreshonly => true,
    }
    if $custom_preferences != false {
      Exec["custom_keys"] {
        before => Concatenated_file[apt_config],
      }
    }
  }

  # workaround for preseeded_package component
  file { [ "/var/cache", "/var/cache/local", "/var/cache/local/preseeding" ]: ensure => directory }
}
