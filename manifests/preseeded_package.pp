define apt::preseeded_package ($content = "", $ensure = "installed") {
  $seedfile = "/var/cache/local/preseeding/${name}.seeds"

  file { $seedfile:
    content => $content ? { 
      ""      => template ( "site_apt/${::lsbdistcodename}/${name}.seeds" ),
      default => $content
    },   
    mode => 0600, owner => root, group => root,
  }   

  package { $name:
    ensure => $ensure,
    responsefile => $seedfile,
    require => File[$seedfile],
  }   
}  
