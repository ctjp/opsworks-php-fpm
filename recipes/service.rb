service 'php-fpm' do
  service_name node['php-fpm']['service_name']
  supports :status => true, :restart => true, :reload => true
  action :nothing
end
