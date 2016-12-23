# watch .d directories and ensure they are present

class apt::dot_d_directories {

  file {
    '/etc/apt/apt.conf.d':
      ensure   => directory,
      checksum => mtime,
      notify   => Exec['update_apt'];

    '/etc/apt/sources.list.d':
      ensure   => directory,
      checksum => mtime,
      notify   => Exec['update_apt'];
  }
}
