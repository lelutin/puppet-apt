# This is a wrapper that will be removed after a while
define apt::preseeded_package (
  $ensure  = 'present',
  $content = '',
) {
  warning('apt::preseeded_package is deprecated! you should now use apt::package instead.')
  apt::package { $name:
    ensure  => $ensure,
    content => $content,
  }
}
