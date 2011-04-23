define apt::custom_sources_template ($sources_file = "") {

  include apt::update

  file { "/etc/apt/sources.list.d/$sources_file":
            content => template($name),
	    notify => Exec['apt_updated'] 
  }
}

