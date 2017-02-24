# = Define: apt::dpkg_statoverride
#
# Override ownership and mode of files
#
#
# == Parameters
#
# [*name*]
#   Implicit parameter.
#   File path.
#
# [*user*]
#   User name (or user id if prepended with '#').
#
# [*group*]
#   Group name (or group id if prepended with '#').
#
# [*mode*]
#   File mode, in octal
#
# [*ensure*]
#   Whether to add or delete this configuration
#
#
# == Examples
#
# Usage:
# apt::dpkg_statoverride { '/var/log/puppet':
#   user  => 'puppet',
#   group => 'puppet',
#   mode  => '750',
# }
#
# == License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# == Copyright
#
# Copyright 2014-2016 Mathieu Parent
#
define apt::dpkg_statoverride(
  $user,
  $group,
  $mode,
  $ensure = present
) {
  case $ensure {
    'present': {
      exec { "dpkg_statoverride_${name}-add":
        command => "dpkg-statoverride --update --add '${user}' '${group}' '${mode}' '${name}'",
        unless  => "dpkg-statoverride --list '${name}' | grep '${user} ${group} ${mode} ${name}'",
      }
    }
    'absent': {
      exec { "dpkg_statoverride_${name}-add":
        command => "dpkg-statoverride --remove '${name}'",
        onlyif  => "dpkg-statoverride --list '${name}'",
      }
    }
    default: {
      fail("Unknown value for \$ensure: '${ensure}'")
    }
  }
}
