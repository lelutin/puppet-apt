class apt::proxy-client {

  $real_apt_proxy = $apt_proxy ? {
    "" => "localhost",
    default => $apt_proxy
  }

  $real_apt_proxy_port = $apt_proxy_port ? {
    "" => "3142",
    default => $apt_proxy_port
  }

  apt_conf_snippet { "20proxy":
    content => template("apt/20proxy.erb"),
  }
}
