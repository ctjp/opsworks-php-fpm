require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

# Set php-fpm service name
service_name = 'php-fpm'
version = ''
conf_file = '/etc/' + service_name + (!version.empty? ? '-' + version : '') + '.conf'
pool_conf_dir = '/etc/' + service_name + (!version.empty? ? '-' + version : '') + '.d'
pools = [
  {
    'name' => 'www'
  }
]

describe package('php') do
  it { should be_installed }
end

describe package('php-fpm') do
  it { should be_installed }
end

describe file(conf_file) do
  it { should be_file }
end

describe file(pool_conf_dir) do
  it { should be_directory }
end

pools.each do |pool|
  pool_name = ''
  pool.each do |param, value|
    if param == 'name'
      pool_name = value
      describe file(pool_conf_dir + '/' + pool_name + '.conf') do
        it { should be_file }
      end

      describe file(pool_conf_dir + '/' + pool_name + '.conf') do
        it { should contain '[' + pool_name + ']' }
      end
    else
      next
    end
  end
end
