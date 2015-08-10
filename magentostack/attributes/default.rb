normal[:mod_php5_apache2][:packages] = [ 'php5-curl', 'php5-gd', 'php5-cli', 'php5-mysql', 'php5-mcrypt' ]
normal[:opsworks][:deploy_keep_releases] = 3

#normal['newrelic']['license'] = 'configure in stack json'

normal['newrelic']['server_monitoring']['license'] = node['newrelic']['license']
normal['newrelic']['application_monitoring']['license'] = node['newrelic']['license']
normal['newrelic']['plugin_monitoring']['license'] = node['newrelic']['license']
normal['newrelic']['server_monitoring']['hostname'] = "magento_#{node[:opsworks][:instance][:hostname]}"

normal['newrelic']['application_monitoring']['enabled'] = true
normal['newrelic']['application_monitoring']['appname'] = "Magento"

# This can't be empty, but php::default doesn't exist on OpsWorks, so we simply run an empty dummy...
normal['newrelic']['php-agent']['php_recipe'] = 'magentostack::dummy'
normal['newrelic']['php-agent']['config_file'] = "/etc/php5/mods-available/newrelic.ini"