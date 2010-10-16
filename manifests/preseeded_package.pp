define apt::preseeded_package ($content = "", $ensure = "installed") {
  $seedfile = "/var/cache/local/preseeding/$name.seeds"
  $real_content = $content ? { 
    ""      => template ( "$name.seeds", "$debian_version/$name.seeds" ),
    default => $content
  }   

  file{ $seedfile:
    content => $real_content,
    mode => 0600, owner => root, group => root,
  }   

  package { $name:
    ensure => $ensure,
    responsefile => $seedfile,
    require => File[$seedfile],
  }   
}  
