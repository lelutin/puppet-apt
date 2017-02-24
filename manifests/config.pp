class apt::config {

  exec { 'update_apt':
    command     => '/usr/bin/apt-get update',
    require     => [ File['/etc/apt/apt.conf.d',
                          '/etc/apt/sources.list'] ],
    refreshonly => true;
  }

  $sources_content = $apt::custom_sources_list ? {
    ''      => template( "apt/${::operatingsystem}/sources.list.erb"),
    default => $apt::custom_sources_list,
  }
  file {
    # include main and security
    # additional sources should be included via the apt::sources_list define
    '/etc/apt/sources.list':
      content => $sources_content,
      notify  => Exec['update_apt'],
      owner   => root,
      group   => 0,
      mode    => '0644';
  }

  # workaround for preseeded_package component
  file {
    [ '/var/cache',
      '/var/cache/local',
      '/var/cache/local/preseeding' ]:
        ensure => directory;
  }

  ::apt::apt_conf { '02show_upgraded':
    source => [ "puppet:///modules/site_apt/${::fqdn}/02show_upgraded",
                'puppet:///modules/site_apt/02show_upgraded',
                'puppet:///modules/apt/02show_upgraded' ];
  }

  if ( $::virtual == 'vserver' ) {
    ::apt::apt_conf { '03clean_vserver':
      source => [ "puppet:///modules/site_apt/${::fqdn}/03clean_vserver",
                  'puppet:///modules/site_apt/03clean_vserver',
                  'puppet:///modules/apt/03clean_vserver' ],
      alias  => '03clean';
    }
  }
  else {
    ::apt::apt_conf { '03clean':
      source => [ "puppet:///modules/site_apt/${::fqdn}/03clean",
                  'puppet:///modules/site_apt/03clean',
                  'puppet:///modules/apt/03clean' ];
    }
  }

  if ($apt::use_backports and !($::debian_release in ['testing', 'unstable', 'experimental'])) {
    apt::sources_list {
      'backports':
        content => "deb ${apt::debian_url} ${::debian_codename}-backports ${apt::repos}",
    }
    if $apt::include_src {
      apt::sources_list {
        'backports-src':
          content => "deb-src ${apt::debian_url} ${::debian_codename}-backports ${apt::repos}",
      }
    }
  }

  if $apt::custom_key_dir {
    file { "${apt::apt_base_dir}/keys.d":
      source  => $apt::custom_key_dir,
      recurse => true,
      owner   => root,
      group   => root,
      mode    => '0755',
    }
    exec { 'custom_keys':
      command     => "find ${apt::apt_base_dir}/keys.d -type f -exec apt-key add '{}' \\;",
      subscribe   => File["${apt::apt_base_dir}/keys.d"],
      refreshonly => true,
      notify      => Exec['update_apt'];
    }
    if $apt::custom_preferences != false {
      Exec['custom_keys'] {
        before => File['apt_config'],
      }
    }
  }
}
