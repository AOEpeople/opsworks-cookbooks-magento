include_recipe "apache2::service"

include_recipe 'newrelic::default'
include_recipe 'newrelic::php-agent'

# New Relic creates these extra files which override settings from the correct file (/etc/php5/mods-available/newrelic.ini)
file "/etc/php5/cli/conf.d/newrelic.ini" do
  action :delete
end

file "/etc/php5/apache2/conf.d/newrelic.ini" do
  action :delete
  notifies :restart, "service[#{node['newrelic']['php-agent']['web_server']['service_name']}]", :delayed
end

bash 'configure newrelic appname for cli' do
  code <<-EOH
    sed -i '/newrelic/d' /etc/php5/cli/php.ini
    echo "newrelic.appname = \"#{node['newrelic']['application_monitoring']['appname']} CLI\"" >> /etc/php5/cli/php.ini
    EOH
end