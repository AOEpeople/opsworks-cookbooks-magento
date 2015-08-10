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