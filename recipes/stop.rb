include_recipe 'php-fpm::service'

service node['php-fpm']['service_name'] do
  action :stop
end
