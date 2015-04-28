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

group 'www-data' do
  action :modify
  members 'deploy'
  append true
end

execute "install mcrypt" do
  command "php5enmod mcrypt"
  user 'root'
  notifies :restart, "service[apache2]", :delayed
end