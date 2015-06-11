define apt::key ($source) {
  file {
    "${apt::apt_base_dir}/${name}":
      source  => $source;
    "${apt::apt_base_dir}/keys":
      ensure  => directory;
  }
  exec { "apt-key add ${apt::apt_base_dir}/${name}":
    subscribe   => File["${apt::apt_base_dir}/${name}"],
    refreshonly => true,
    notify      => Exec['refresh_apt'],
  }
}
