require 'spec_helper'

describe 'php-fpm::default' do
  # Set php-fpm service name
  packages = %w(php php-fpm)
  service_name = 'php-fpm'
  version = ''
  conf_file = '/etc/' + service_name + (!version.empty? ? '-' + version : '') + '.conf'
  pool_conf_dir = '/etc/' + service_name + (!version.empty? ? '-' + version : '') + '.d'
  php_fpm = {
    'service_name' => service_name,
    'version' => version,
    'conf_file' => conf_file,
    'pool_conf_dir' => pool_conf_dir,
    'pid' => '/var/run/php-fpm' + (version.empty? ? '' : '/' + version) + '/php-fpm.pid',
    'error_log' => '/var/log/php-fpm/error.log',
    'log_level' => 'notice',
    'emergency_restart_threshold' => 0,
    'emergency_restart_interval' => 0,
    'process_control_timeout' => 0,
    'pools' => [
      {
        'name' => 'www',
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
    ]
  }
  pools = php_fpm['pools']

  let(:chef_run) do
    ChefSpec::Runner.new(:platform => 'centos', :version => '6.5') do |node|
      node.set['php']['packages'] = packages
      node.set['php-fpm'] = php_fpm
    end.converge(described_recipe)
  end

  before do
    stub_command('test -d ' + pool_conf_dir + ' || mkdir -p ' + pool_conf_dir).and_return(true)
  end

  it 'includes recipe php' do
    chef_run.should include_recipe 'php'
  end

  packages.each do |package|
    it 'installs ' + package do
      chef_run.should install_package package
    end
  end

  it 'creates ' + conf_file do
    chef_run.should create_template conf_file
  end

  php_fpm.each do |param, value|
    if %w(pid error_log log_level emergency_restart_threshold emergency_restart_interval process_control_timeout).include? param
      it 'renders ' + conf_file + ' with content "' + param + ' = ' + value.to_s + '"' do
        chef_run.should render_file(conf_file).with_content(param + ' = ' + value.to_s)
      end
    else
      next
    end
  end

  pools.each do |pool|
    pool_name = ''
    pool.each do |param, value|
      if param == 'name'
        pool_name = value

        it 'creates ' + pool_conf_dir + '/' + pool_name + '.conf' do
          chef_run.should create_template pool_conf_dir + '/' + pool_name + '.conf'
        end
        it 'renders ' + pool_conf_dir + '/' + pool_name + '.conf' + ' with content "[' + pool_name + ']"' do
          chef_run.should render_file(pool_conf_dir + '/' + pool_name + '.conf').with_content('[' + pool_name + ']')
        end
      elsif param == 'process_manager'
        it 'renders ' + pool_conf_dir + '/' + pool_name + '.conf' + ' with content "pm = ' + value + '"' do
          chef_run.should render_file(pool_conf_dir + '/' + pool_name + '.conf').with_content('pm = ' + value)
        end
      elsif param == 'security_limit_extensions'
        it 'renders ' + pool_conf_dir + '/' + pool_name + '.conf' + ' with content "security.limit_extensions = ' + value + '"' do
          chef_run.should render_file(pool_conf_dir + '/' + pool_name + '.conf').with_content('security.limit_extensions = ' + value)
        end
      elsif %w(catch_workers_output slowlog).include? param
        it 'renders ' + pool_conf_dir + '/' + pool_name + '.conf' + ' with content "' + param + ' = ' + value + '"' do
          chef_run.should render_file(pool_conf_dir + '/' + pool_name + '.conf').with_content(param + ' = ' + value)
        end
      elsif param == 'php_options'
        value.each do |option, opt_value|
          it 'renders ' + pool_conf_dir + '/' + pool_name + '.conf' + ' with content "' + option + ' = ' + opt_value.to_s + '"' do
            chef_run.should render_file(pool_conf_dir + '/' + pool_name + '.conf').with_content(option + ' = ' + opt_value.to_s)
          end
        end
      else
        it 'renders ' + pool_conf_dir + '/' + pool_name + '.conf' + ' with content "pm.' + param + ' = ' + value.to_s + '"' do
          chef_run.should render_file(pool_conf_dir + '/' + pool_name + '.conf').with_content('pm.' + param + ' = ' + value.to_s)
        end
      end
    end
  end
end
