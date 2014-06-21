default['php-fpm']['service_name'] = 'php-fpm'
default['php-fpm']['user'] = 'nginx'
default['php-fpm']['group'] = 'nginx'
default['php-fpm']['conf_dir'] = '/etc/php.d'
default['php-fpm']['pool_conf_dir'] = '/etc/php-fpm.d'
default['php-fpm']['conf_file'] = '/etc/php-fpm.conf'
default['php-fpm']['pid'] = '/var/run/php-fpm/php-fpm.pid'
default['php-fpm']['error_log'] = '/var/log/php-fpm/error.log'
default['php-fpm']['log_level'] = 'notice'
default['php-fpm']['emergency_restart_threshold'] = 0
default['php-fpm']['emergency_restart_interval'] = 0
default['php-fpm']['process_control_timeout'] = 0
default['php-fpm']['pool_defaults'] = {
  'process_manager' => 'dynamic',
  'max_children' => 50,
  'start_servers' => 5,
  'min_spare_servers' => 5,
  'max_spare_servers' => 35,
  'max_requests' => 500,
  'catch_workers_output' => 'no',
  'security_limit_extensions' => '.php',
  'slowlog' => '/var/log/php-fpm/slow.log',
  'php_options' => {
    'php_admin_value[memory_limit]' => '128M',
    'php_admin_value[error_log]' => '/var/log/php-fpm/@version@poolerror.log',
    'php_admin_flag[log_errors]' => 'on',
    'php_value[session.save_handler]' => 'files',
    'php_value[session.save_path]' => '/var/lib/php/@versionsession'
  }
}
default['php-fpm']['pools'] = [
  {
    'name' => 'www'
  }
]
