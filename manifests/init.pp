# apt.pp - common components and defaults for handling apt
# Copyright (C) 2008 Micah Anerson <micah@riseup.net>
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class apt (
  $use_lts             = $apt::params::use_lts,
  $use_volatile        = $apt::params::use_volatile,
  $use_backports       = $apt::params::use_backports,
  $include_src         = $apt::params::include_src,
  $use_next_release    = $apt::params::use_next_release,
  $debian_url          = $apt::params::debian_url,
  $security_url        = $apt::params::security_url,
  $lts_url             = $apt::params::lts_url,
  $volatile_url        = $apt::params::volatile_url,
  $ubuntu_url          = $apt::params::ubuntu_url,
  $repos               = $apt::params::repos,
  $manage_preferences  = $apt::params::manage_preferences,
  $custom_preferences  = $apt::params::custom_preferences,
  $custom_sources_list = '',
  $custom_key_dir      = $apt::params::custom_key_dir,
) inherits apt::params {

  include apt::dot_d_directories
  include apt::config
  include apt::install
  include apt::preferences

  include common::moduledir
  common::module_dir { 'apt': }
  $apt_base_dir = "${common::moduledir::module_dir_path}/apt"

}
