# apt.pp - common components and defaults for handling apt
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
#
# With hints from
#  Micah Anderson <micah@riseup.net>
#  * backports key

class apt {

	# See README
	$real_apt_clean = $apt_clean ? {
		'' => 'auto',
		default => $apt_clean,
	}

	package { apt: ensure => installed }

	# a few templates need lsbdistcodename
	include assert_lsbdistcodename

	case $custom_sources_list {
		'': {
			include default_sources_list
		}
		default: {
			config_file { "/etc/apt/sources.list":
				content => $custom_sources_list
				require => Exec[assert_lsbdistcodename];
			}
		}
	}

	class default_sources_list {
		config_file {
			# include main, security and backports
			# additional sources could be included via an array
			"/etc/apt/sources.list":
				content => template("apt/sources.list.erb"),
				require => Exec[assert_lsbdistcodename];
		}
	}

        case $custom_preferences {
          '': {
            include default_preferences
          }
          default: {
            config_file { "/etc/apt/preferences":
              content => $custom_preferences
              alias => apt_config,
              require => File["/etc/apt/sources.list"];
            }
          }
        }
        class default_preferences {
	  config_file {
	    # this just pins unstable and testing to very low values
	    "/etc/apt/preferences":
	      content => template("apt/preferences.erb"),
	      # use File[apt_config] to reference a completed configuration
	      # See "The Puppet Semaphor" 2007-06-25 on the puppet-users ML
	      alias => apt_config,
	      # only update together
	      require => File["/etc/apt/sources.list"];
	    # little default settings which keep the system sane
	    "/etc/apt/apt.conf.d/from_puppet":
	      content => "APT::Get::Show-Upgraded true;\nDSelect::Clean $real_apt_clean;\n",
	      before => File[apt_config];
	  }
        }

	$apt_base_dir = "/var/lib/puppet/modules/apt"
	modules_dir { apt: }
	# watch apt.conf.d
	file { "/etc/apt/apt.conf.d": ensure => directory, checksum => mtime; }

	exec {
		# "&& sleep 1" is workaround for older(?) clients
		"/usr/bin/apt-get update && sleep 1 #on refresh":
			refreshonly => true,
			subscribe => [ File["/etc/apt/sources.list"],
				File["/etc/apt/preferences"], File["/etc/apt/apt.conf.d"],
				File[apt_config] ];
		"/usr/bin/apt-get update && /usr/bin/apt-get autoclean #hourly":
			require => [ File["/etc/apt/sources.list"],
				File["/etc/apt/preferences"], File[apt_config] ],
			# Another Semaphor for all packages to reference
			alias => apt_updated;
	}

        ## This package should really always be current
        package { "debian-archive-keyring":
          ensure => latest,
        }
          
	case $lsbdistcodename {
		etch: {
		  package { "debian-backports-keyring":
		    ensure => latest,
		  }
                  
		  # This key was downloaded from
		  # http://backports.org/debian/archive.key
		  # and is needed to bootstrap the backports trustpath
		  file { "${apt_base_dir}/backports.org.key":
		    source => "puppet://$servername/apt/backports.org.key",
		    mode => 0444, owner => root, group => root,
		  }
		  exec { "/usr/bin/apt-key add ${apt_base_dir}/backports.org.key && apt-get update":
		    alias => "backports_key",
		    refreshonly => true,
		    subscribe => File["${apt_base_dir}/backports.org.key"],
		    before => [ File[apt_config], Package["debian-backports-keyring"] ]
		  }
		}
	}
}

class dselect {
	# suppress annoying help texts of dselect
	line { dselect_expert:
		file => "/etc/dpkg/dselect.cfg",
		line => "expert",
		ensure => present,
	}

	package { dselect: ensure => installed }
}
