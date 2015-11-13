#
# Cookbook Name:: magentostack
# Recipe:: setup
#
# This cookbook is intended to be run with the "setup" cookbooks in AWS OpsWorks' default PHP Layer
#
# @since 2014-06-14
# @author Fabrizio Branca
#

Chef::Log.info("Recipe magentostack::setup")

# Add user 'ubuntu' to group 'www-data'
group 'www-data' do
  action :modify
  members 'ubuntu'
  append true
end

execute "install mcrypt" do
  command "php5enmod mcrypt"
  user 'root'
  notifies :restart, "service[apache2]", :delayed
end

node[:deploy].each do |application, deploy|
  template "/etc/logrotate.d/magentologs_#{application}" do
    backup false
    source "logrotate.erb"
    cookbook 'magentostack'
    owner "root"
    group "root"
    mode 0644
    variables( :log_dirs => ["#{deploy[:deploy_to]}/shared/var/log" ] )
  end
end