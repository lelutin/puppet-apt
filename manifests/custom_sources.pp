define apt::custom_sources_template ($sources_file = "") {
    file { "/etc/apt/sources.list.d/$sources_file":
                   content => template($name),
		notify => Exec['refresh_apt']    
     }
}

