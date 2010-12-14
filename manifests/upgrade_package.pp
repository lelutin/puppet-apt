define apt::upgrade_package ($version = "") {

  case $version {
    '', 'latest': {
      exec { "aptitude -y install $name":
        onlyif => [ "grep-status -F Status installed -a -P $name -q", "apt-show-versions -u $name | grep -q upgradeable" ],
      }
    }
    default: {
      exec { "aptitude -y install $name=$version":
        onlyif => [ "grep-status -F Status installed -a -P $name -q", "apt-show-versions -u $name | grep -q upgradeable" ],
      }
    }
  }
}
