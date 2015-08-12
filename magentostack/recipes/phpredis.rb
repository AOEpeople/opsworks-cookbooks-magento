include_recipe "apache2::service"

package 'php5-dev' do
  action :upgrade
end

%w(igbinary phpredis).each do |name|
  directory "/tmp/#{name}" do
    owner "root"
    group "root"
    mode "0755"
    action :create
  end
end

git "/tmp/igbinary" do
  repository "git://github.com/igbinary/igbinary.git"
  revision "master"
  action :sync
  not_if "php -m | grep redis"
end
git "/tmp/phpredis" do
  repository "git://github.com/phpredis/phpredis.git"
  revision "develop"
  action :sync
  not_if "php -m | grep redis"
end

bash "install igbinary and phpredis" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    cd /tmp/igbinary && phpize && ./configure && make && make install
    cd /tmp/phpredis && phpize && ./configure --enable-redis-igbinary && make && make install
  EOH
  not_if "php -m | grep redis"
end

%w(apache2 cli).each do |name|
  file "/etc/php5/#{name}/conf.d/30-phpredis.ini" do
    action :create
    content "extension=igbinary.so\nextension=redis.so\n"
  end
end

execute "restart apache" do
  command "echo 'Restarting Apache now'"
  action :run
  notifies :restart, "service[apache2]"
end