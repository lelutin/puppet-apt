# apt module

#### Table of Contents

* [Overview](#overview)
  * [Upgrade Notice](#upgrade-notice)
* [Requirements](#requirements)
* [Classes](#classes)
  * [apt](#apt)
  * [apt::apticron](#apt-apticron)
  * [apt::cron::download](#apt-cron-download)
  * [apt::cron::dist_upgrade](#apt-cron-dist_upgrade)
  * [apt::dist_upgrade](#apt-dist_upgrade)
  * [apt::dist_upgrade::initiator](#apt-dist_upgrade-initiator)
  * [apt::dselect](#apt-dselect)
  * [apt::listchanges](#apt-listchanges)
  * [apt::proxy_client](#apt-proxy_client)
  * [apt::reboot_required_notify](#apt-reboot_required_notify)
  * [apt::unattended_upgrades](#apt-unattended_upgrades)
* [Defines](#defines)
  * [apt::apt_conf](#apt-apt_conf)
  * [apt::preferences_snippet](#apt-preferences_snippet)
  * [apt::preseeded_package](#apt-preseeded_package)
  * [apt::sources_list](#apt-sources_list)
  * [apt::key](#apt-key)
  * [`apt::key::plain`](#apt-key-plain)
  * [apt::upgrade_package](#apt-upgrade_package)
* [Resources](#ressources)
  * [File\['apt_config'\]](#fileapt_config)
  * [Exec\['apt_updated'\]](#execapt_updated)
* [Tests](#tests)
  * [Acceptance Tests](#acceptance-tests)
* [Licensing](#licensing)


# Overview<a name="overview"></a>

This module manages apt on Debian.

It keeps dpkg's and apt's databases as well as the keyrings for securing
package download current.

backports.debian.org is added.

`/etc/apt/sources.list` and `/etc/apt/preferences` are managed. More
recent Debian releases are pinned to very low values by default to
prevent accidental upgrades.

Ubuntu support is lagging behind but not absent either.

## Upgrade Notice<a name="upgrade-notice"></a>

 * The default value of the `$repos` parameter was removed since the logic is
    now in the `apt::params` class. If you have explicitly set `$repos` to
    'auto' in your manifests, you should remove this.
 
 * The `disable_update` parameter has been removed. The main apt class
   defaults to *not* run an `apt-get update` on every run anyway so this
   parameter seems useless.
   You can include the `apt::update` class if you want it to be run every time.

 * The `apt::upgrade_package` now doesn't automatically call an `Exec['apt_updated']`
   anymore, so you would need to include `apt::update` now by hand.

 * The `apt::codename` parameter has been removed. In its place, the
   `debian_codename` fact may be overridden via an environment variable. This
   will affect all other `debian_*` facts, and achieve the same result.

    FACTER_debian_codename=jessie puppet agent -t

 * If you were using custom `50unattended-upgrades.${::lsbdistcodename}` in your
   `site_apt`, these are no longer supported. You should migrate to passing
   `$blacklisted_packages` to the `apt::unattended_upgrades` class.

 * the apt class has been moved to a paramterized class. if you were including
   this class before, after passing some variables, you will need to move to
   instantiating the class with those variables instead. For example, if you 
   had the following in your manifests:

    $ apt_debian_url = 'http://localhost:9999/debian/'
    $ apt_use_next_release = true
    include apt
 
   you will need to remove the variables, and the include and instead do
   the following:

    class { 'apt':
      debian_url       => 'http://localhost:9999/debian/',
      use_next_release => true;
    }

   previously, you could manually set `$lsbdistcodename` which would enable forced
   upgrades, but because this is a top-level facter variable, and newer puppet
   versions do not let you assign variables to other namespaces, this is no
   longer possible. However, there is a way to obtain this functionality, and
   that is to pass the 'codename' parameter to the apt class, which will change
   the `sources.list` and `preferences` files to be the codename you set, allowing
   you to trigger upgrades:

    include apt::dist_upgrade
    class { 'apt':
      codename => 'wheezy',
      notify   => Exec['apt_dist-upgrade'];
    }

 * the `apticron` class has been moved to a parameterized class.  if you were
   including this class before, you will need to move to instantiating the
   class instead. For example, if you had the following in your manifests:

    $apticron_email = 'foo@example.com'
    $apticron_notifynew = '1'
    ... any $apticron_* variables
    include apticron

   you will need to remove the variables, and the include and instead do the
   following:

    class { 'apt::apticron':
      email     => 'foo@example.com',
      notifynew => '1';
    }

 * the `apt::listchanges` class has been moved to a paramterized class. if you
   were including this class before, after passing some variables, you will need
   to move to instantiating the class with those variables instead. For example,
   if you had the following in your manifests:

    $apt_listchanges_email = 'foo@example.com'
    ... any $apt_listchanges_* variables
    include apt::listchanges

   you will need to remove the variables, and the include and instead do the
   following:
 
    class { 'apt::listchanges':
      email => 'foo@example.com';
    }
   
 * the `apt::proxy_client` class has been moved to a paramterized class. if you
   were including this class before, after passing some variables, you will need
   to move to instantiating the class with those variables instead. For example,
   if you had the following in your manifests:

    $apt_proxy = 'http://proxy.domain'
    $apt_proxy_port = 666
    include apt::proxy_client

   you will need to remove the variables, and the include and instead do the
   following:

    class { 'apt::proxy_client':
      proxy => 'http://proxy.domain',
      port  => '666';
    }


# Requirements<a name="requirements"></a>

This module needs:

 * the `lsb-release` package should be installed on the server prior to running
  puppet. otherwise, all of the `$::lsb*` facts will be empty during runs.

 * the [common module](https://gitlab.com/shared-puppet-modules-group/common)

By default, on normal hosts, this module sets the configuration option
`DSelect::Clean` to 'auto'. On virtual servers, the value is set by default to
'pre-auto', because virtual servers are usually more space-bound and have better
recovery mechanisms via the host:

From apt.conf(5), 0.7.2:
     "Cache Clean mode; this value may be one of always, prompt, auto,
     pre-auto and never. always and prompt will remove all packages
     from the cache after upgrading, prompt (the default) does so
     conditionally.  auto removes only those packages which are no
     longer downloadable (replaced with a new version for
     instance). pre-auto performs this action before downloading new
     packages."

To change the default setting for `DSelect::Clean`, you can create a file named
"03clean" or "03clean_vserver" in your `site_apt` module's files directory. You
can also define this for a specific host by creating a file in a subdirectory of
the `site_apt` modules' files directory that is named the same as the
host. (example: site_apt/files/some.host.com/03clean, or
site_apt/files/some.host.com/03clean_vserver)


# Classes<a name="classes"></a>

## apt<a name="apt"></a>

The apt class sets up most of the documented functionality. To use functionality
that is not enabled by default, you must set one of the following parameters.

Example usage:

    class { 'apt':
      use_next_release => true,
      debian_url       => 'http://localhost:9999/debian/',
    }

**Class parameters:**

### use_lts

  If this variable is set to true the CODENAME-lts sources (such as
  squeeze-lts) are added.

  By default this is false for backward compatibility with older
  versions of this module.

### use_volatile

  If this variable is set to true the CODENAME-updates sources (such as
  squeeze-updates) are added.

  By default this is false for backward compatibility with older
  versions of this module.

### include_src

  If this variable is set to true a deb-src source is added for every
  added binary archive source.

  By default this is false for backward compatibility with older
  versions of this module.

### use_next_release

  If this variable is set to true the sources for the next Debian
  release are added. The default pinning configuration pins it to very
  low values.

  By default this is false for backward compatibility with older
  versions of this module.

### debian_url, security_url, backports_url, volatile_url

  These variables allow to override the default APT mirrors respectively
  used for the standard Debian archives, the Debian security archive,
  the Debian official backports and the Debian Volatile archive.

### ubuntu_url

  These variables allows to override the default APT mirror used for all
  standard Ubuntu archives (including updates, security, backports).

### repos

  If this variable is set the default repositories list ("main contrib non-free")
  is overriden.

### custom_preferences

  For historical reasons (Debian Lenny's version of APT did not support the use
  of the `preferences.d` directory for putting fragments of 'preferences'), this
  module will manage a default generic apt/preferences file with more
  recent releases pinned to very low values so that any package
  installation will not accidentally pull in packages from those suites
  unless you explicitly specify the version number. This file will be
  complemented with all of the preferences_snippet calls (see below).

  If the default preferences template doesn't suit your needs, you can create a
  template located in your `site_apt` module, and set custom_preferences with the
  content (eg. custom_preferences => template('site_apt/preferences') )

  Setting this variable to false before including this class will force the
  `apt/preferences` file to be absent:

    class { 'apt':
      custom_preferences => false,
    }
  
### custom_sources_list

  By default this module will use a basic `apt/sources.list` template with
  a generic Debian mirror. If you need to set more specific sources,
  e.g. changing the sections included in the source, etc. you can set
  this variable to the content that you desire to use instead.

  For example, setting this variable will pull in the
  `templates/site_apt/sources.list` file:

    class { 'apt':
      custom_sources_list => template('site_apt/sources.list'),
    }

### custom_key_dir

  If you have different apt-key files that you want to get added to your
  apt keyring, you can set this variable to a path in your fileserver
  where individual key files can be placed. If this is set and keys
  exist there, this module will `apt-key add` each key.

  The debian-archive-keyring package is installed and kept current up to the
  latest revision (this includes the backports archive keyring).


## apt::apticron<a name="apt-apticron"></a>

When you instantiate this class, apticron will be installed, with the following
defaults, which you are free to change:

    $ensure_version = 'installed',
    $config = "apt/${::operatingsystem}/apticron_${::lsbdistcodename}.erb",
    $email = 'root',
    $diff_only = '1',
    $listchanges_profile = 'apticron',
    $system = false,
    $ipaddressnum = false,
    $ipaddresses = false,
    $notifyholds = '0',
    $notifynew = '0',
    $customsubject = ''

Example usage:

    class { 'apt::apticron':
      email     => 'foo@example.com',
      notifynew => '1',
    }


## apt::cron::download<a name="apt-cron-download"></a>

This class sets up `cron-apt` so that it downloads upgradable packages, does not
actually do any upgrade and emails when the output changes.

`cron-apt` defaults to run at 4 AM. You may want to set the
`$apt_cron_hours` variable before you include the class: its value will
be passed as the "hours" parameter of a cronjob. Example:

    # Run cron-apt every three hours
    $apt_cron_hours = '*/3'

Note that the default 4 AM cronjob won't be disabled.


## apt::cron::dist_upgrade<a name="apt-cron-dist_upgrade"></a>

This class sets up cron-apt so that it dist-upgrades the system and
emails when upgrades are performed.

See [apt::cron::download](#apt-cron-download) above if you need to run `cron-apt` more often
than once a day.


## apt::dist_upgrade<a name="apt-dist_upgrade"></a>

This class provides the `Exec['apt_dist-upgrade']` resource that
dist-upgrade's the system.

This exec is set as refreshonly so including this class does not
trigger any action per-se: other resources may notify it, other
classes may inherit from this one and add to its subscription list
using the plusignment (`+>`) operator. A real-world example can be
seen in the `apt::dist_upgrade::initiator` source.


## apt::dist_upgrade::initiator<a name="apt-dist_upgrade-initiator"></a>

This class automatically dist-upgrade's the system when an initiator
file's content changes. The initiator file is copied from the first
available source amongst the following ones, in decreasing priority
order:

 * `puppet:///modules/site_apt/${::fqdn}/upgrade_initiator`

 * `puppet:///modules/site_apt/upgrade_initiator`

 * `puppet:///modules/apt/upgrade_initiator`

This is useful when one does not want to setup a fully automated
upgrade process but still needs a way to manually trigger full
upgrades of any number of systems at scheduled times.

**Beware:** a `dist-upgrade` is triggered the first time Puppet runs after
this class has been included. This is actually the single reason why
this class is not enabled by default.

When this class is included the APT indexes are updated on every
Puppet run due to the author's lack of Puppet wizardry.


## apt::dselect<a name="apt-dselect"></a>

This class, when included, installs dselect and switches it to expert mode to
suppress superfluous help screens.


## apt::listchanges<a name="apt-listchanges"></a>

This class, when instantiated, installs `apt-listchanges` and configures it using
the following parameterized variables, which can be changed:

    version = 'present'
    config = "apt/${::operatingsystem}/listchanges_${::lsbrelease}.erb"
    frontend = 'pager'
    email = 'root'
    confirm = 0
    saveseen = '/var/lib/apt/listchanges.db'
    which = 'both'

Example usage:

    class { 'apt::listchanges':
      email => 'foo@example.com',
    }
 

## apt::proxy_client<a name="apt-proxy_client"></a>

This class adds the right configuration to apt to make it fetch packages via a
proxy. The class parameters `apt_proxy` and `apt_proxy_port` need to be set:

You can set the `proxy` class parameter variable to the URL of the proxy that
will be used.  By default, the proxy will be queried on port 3142, but you can
change the port number by setting the `port` class parameter.

Example usage:

    class { 'apt::proxy_client':
      proxy => 'http://proxy.domain',
      port  => '666',
    }


## apt::reboot_required_notify<a name="apt-reboot_required_notify"></a>

This class installs a daily cronjob that checks if a package upgrade
requires the system to be rebooted; if so, cron sends a notification
email to root.


## apt::unattended_upgrades<a name="apt-unattended_upgrades"></a>

If this class is included, it will install the package `unattended-upgrades`
and configure it to daily upgrade the system.

The class has the following parameters that you can use to change the contents
of the configuration file. The values shown here are the default values:

    $config_content = undef
    $config_template = 'apt/50unattended-upgrades.erb'
    $mailonlyonerror = true
    $mail_recipient = 'root'
    $blacklisted_packages = []

Note that using `$config_content` actually specifies all of the configuration
contents and thus makes the other parameters useless.

Example usage:

    class { 'apt::unattended_upgrades':
      config_template      => 'site_apt/50unattended-upgrades.jessie',
      blacklisted_packages => [ 'libc6', 'libc6-dev', 'libc6-i686',
                                'mysql-server', 'redmine', 'nodejs', 'bird' ],
    }


# Defines<a name="defines"></a>

## apt::apt_conf<a name="apt-apt_conf"></a>

Creates a file in the `apt/apt.conf.d` directory to easily add configuration
components. One can use either the `source` meta-parameter to specify a list of
static files to include from the puppet fileserver or the `content`
meta-parameter to define content inline or with the help of a template.

Example usage:

    apt::apt_conf { '80download-only':
      source => 'puppet:///modules/site_apt/80download-only',
    }


## apt::preferences_snippet<a name="apt-preferences_snippet"></a>

A way to add pinning information to files in `/etc/apt/preferences.d/`

Examples:

    apt::preferences_snippet { 'irssi-plugin-otr':
      release  => 'squeeze-backports',
      priority => 999,
    }

    apt::preferences_snippet { 'unstable_fallback':
      package  => '*',
      release  => 'unstable',
      priority => 1,
    }

    apt::preferences_snippet { 'ttdnsd':
      pin      => 'origin deb.torproject.org',
      priority => 999,
    }

The names of the resources will be used as the names of the files in the
preferences.d directory, so you should ensure that resource names follow the
prescribed naming scheme.

From apt_preferences(5):
     Note that the files in the /etc/apt/preferences.d directory are parsed in
     alphanumeric ascending order and need to obey the following naming
     convention: The files have no or "pref" as filename extension and which
     only contain alphanumeric, hyphen (-), underscore (_) and period (.)
     characters - otherwise they will be silently ignored.


## apt::preseeded_package<a name="apt-preseeded_package"></a>

This simplifies installation of packages for which you wish to preseed the
answers to debconf. For example, if you wish to provide a preseed file for the
locales package, you would place the `locales.seed` file in
`site_apt/templates/${::lsbdistcodename}/locales.seeds` and then include the
following in your manifest:

    apt::preseeded_package { locales: }

You can also specify the content of the seed via the content parameter, 
for example:

    apt::preseeded_package { 'apticron':
      content => 'apticron apticron/notification string root@example.com',
    }


## apt::sources_list<a name="apt-sources_list"></a>

Creates a file in the `apt/sources.list.d` directory to easily add additional apt
sources. One can use either the `source` meta-parameter to specify a list of
static files to include from the puppet fileserver or the `content`
meta-parameter to define content inline or with the help of a template. Ending
the resource name in `.list` is optional: it will be automatically added to the
file name if not present in the resource name.

Example usage:

    apt::sources_list { 'company_internals':
      source => [ "puppet:///modules/site_apt/${::fqdn}/company_internals.list",
                  'puppet:///modules/site_apt/company_internals.list' ];
    }


## apt::key<a name="apt-key"></a>

Deploys a secure apt OpenPGP key. This usually accompanies the
sources.list snippets above for third party repositories. For example,
you would do:

    apt::key {
      'neurodebian.gpg':
        ensure => present,
        source => 'puppet:///modules/site_apt/neurodebian.gpg';
    }

This deploys the key in the `/etc/apt/trusted.gpg.d` directory, which
is assumed by secure apt to be binary OpenPGP keys and *not*
"ascii-armored" or "plain text" OpenPGP key material. For the latter,
use `apt::key::plain`.

The `.gpg` extension is compulsory for `apt` to pickup the key properly.


## `apt::key::plain`<a name="apt-key-plain"></a>

Deploys a secure apt OpenPGP key. This usually accompanies the
sources.list snippets above for third party repositories. For example,
you would do:

    apt::key::plain { 'neurodebian.asc':
      source => 'puppet:///modules/site_apt/neurodebian.asc';
    }

This deploys the key in the `${apt_base_dir}/keys` directory (as
opposed to `$custom_key_dir` which deploys it in `keys.d`). The reason
this exists on top of `$custom_key_dir` is to allow a more
decentralised distribution of those keys, without having all modules
throw their keys in the same directory in the manifests.

Note that this model does *not* currently allow keys to be removed!
Use `apt::key` instead for a more practical, revokable approach, but
that needs binary keys.


## apt::upgrade_package<a name="apt-upgrade_package"></a>

This simplifies upgrades for DSA security announcements or point-releases. This
will ensure that the named package is upgraded to the version specified, only if
the package is installed, otherwise nothing happens. If the specified version
is 'latest' (the default), then the package is ensured to be upgraded to the
latest package revision when it becomes available.

For example, the following upgrades the perl package to version 5.8.8-7etch1
(if it is installed), it also upgrades the syslog-ng and perl-modules packages
to their latest (also, only if they are installed):

    upgrade_package {
      'perl':
        version => '5.8.8-7etch1';
      'syslog-ng':
        version => latest;
      'perl-modules':
    }


# Resources<a name="ressources"></a>

## File['apt_config']<a name="file-apt-config"></a>

Use this resource to depend on or add to a completed apt configuration

## Exec['apt_updated']<a name="exec-apt-updated"></a>

After this point the APT indexes are up-to-date.
This resource is set to `refreshonly => true` so it is not run on
every puppetrun. To run this every time, you can include the `apt::update`
class.

This resource is usually used like this to ensure current packages are
installed by Package resources:

    include apt::update
    Package {
      require => Exec['apt_updated']
    }

Note that nodes can be updated once a day by using

    APT::Periodic::Update-Package-Lists "1";

in i.e. `/etc/apt/apt.conf.d/80_apt_update_daily`.


# Tests<a name="test"></a>

To run pupept rspec tests:

    bundle install --path vendor/bundle
    bundle exec rake spec

Verbose Output:
 
    bundle exec rake spec SPEC_OPTS='--format documentation'

Using different facter/puppet versions:

    FACTER_GEM_VERSION=1.6.10 PUPPET_GEM_VERSION=2.7.23 bundle install --path vendor/bundle
    bundle exec rake spec

## Acceptance Tests<a name="acceptance-tests"></a>

At the moment, we use [beaker together with docker](https://github.com/puppetlabs/beaker/blob/master/docs/Docker-Support.md)
to do acceptance testing.
Be sure to have a recent docker version installed.

List configured nodesets:

    bundle exec rake beaker_nodes

Run tests on default node (Debian Jessie):

    bundle exec rake beaker

Run different nodeset:

    BEAKER_set="debian-8-x86_64-docker" bundle exec rspec spec/acceptance/*_spec.rb
 

# Licensing<a name="licensing"></a>

This puppet module is licensed under the GPL version 3 or later. Redistribution
and modification is encouraged.

The GPL version 3 license text can be found in the "LICENSE" file accompanying
this puppet module, or at the following URL:

http://www.gnu.org/licenses/gpl-3.0.html
