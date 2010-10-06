class apt::cron::base {
	package { cron-apt: ensure => installed }
}
