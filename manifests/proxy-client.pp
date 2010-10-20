class apt::proxy-client {

  $real_apt_proxy = $apt_proxy ? {
    "" => "localhost",
    default => $apt_proxy
  }

  $real_apt_proxy_port = $apt_proxy_port ? {
    "" => "3142",
    default => $apt_proxy_port
  }

  file { "/etc/apt/apt.conf.d/20proxy":
    ensure => present,
    content => "Acquire::http { Proxy \"http://$real_apt_proxy:$real_apt_proxy_port\"; };\n",
    owner => root, group => 0, mode => 0644;
  }
}
