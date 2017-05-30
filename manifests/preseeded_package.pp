# This is a wrapper that will be removed after a while
define apt::preseeded_package (
  $ensure  = 'present',
  $content = '',
) {
  warning('apt::preseeded_package is deprecated! you should now use apt::package with parameter use_seed set to true instead.')
  apt::package { $name:
    ensure           => $ensure,
    use_seed         => true,
    seedfile_content => $content,
  }
}
