include_recipe 'php'

template node['php-fpm']['conf_file'] do
  source 'php-fpm.conf.erb'
  mode 00644
  owner 'root'
  group 'root'
end

if node['php-fpm']['pools']
  version = node['php-fpm']['version']
  pool_defaults = node['php-fpm']['pool_defaults']
  pools = node['php-fpm']['pools'].dup

  pools.each_index do |index|
    pool_name = pools[index]['name']
    pool_defaults.each do |conf, conf_value|
      if conf == 'php_options'
        php_options = {}
        pool_defaults[conf].each do |option, opt_value|
          if pools[index][conf] && pools[index][conf][option]
            opt_value = pools[index][conf][option]
          end
          opt_value.gsub! '@version', (version.nil? ? '' : "#{version}/")
          opt_value.gsub! '@pool', "#{pool_name}-"

          php_options[option] = opt_value
        end

        pools[index][conf] = php_options
      else
        pools[index][conf] = pools[index][conf] || conf_value
      end
    end
  end

  # Create pool config
  pools.each do |pool|
    php_fpm_pool pool[:name] do
      pool.each do |key, value|
        self.params[key.to_sym] = value
      end
    end
  end
end
