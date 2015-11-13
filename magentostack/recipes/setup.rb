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

    node['cwlogs']['logfiles']["magento_system_log_#{application}"] = {
        :log_stream_name => "magento_system_log_#{application}",
        :log_group_name => "#{application}",
        :file => "#{deploy[:deploy_to]}/shared/var/log/system.log",
        :datetime_format => '%Y-%m-%dT%H:%M:%S%z',
        :initial_position => 'end_of_file'
    }

    node['cwlogs']['logfiles']["apache_access_log_#{application}"] = {
        :log_stream_name => "apache_access_log_#{application}",
        :log_group_name => "#{application}",
        :file => "/var/log/apache2/#{application}-access.log",
        :datetime_format => '%d/%b/%Y:%H:%M:%S %z',
        :initial_position => 'end_of_file'
    }

    node['cwlogs']['logfiles']["apache_error_log_#{application}"] = {
        :log_stream_name => "apache_error_log_#{application}",
        :log_group_name => "#{application}",
        :file => "/var/log/apache2/#{application}-error.log",
        :datetime_format => '%d/%b/%Y:%H:%M:%S %z',
        :initial_position => 'end_of_file'
    }

end
