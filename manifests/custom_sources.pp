define apt::custom_sources_template ($sources_file = "") {
    file { "/etc/apt/sources.list.d/$sources_file":
                   content => template($name),
     }
    exec { "/usr/bin/apt-get update":
        subscribe => File["/etc/apt/sources.list.d/$sources_file"],
        refreshonly => true,
    }
 }

