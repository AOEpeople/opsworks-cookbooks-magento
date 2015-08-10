#
# Cookbook Name:: newrelic
# Recipe:: java-agent
#
# Copyright 2012-2014, Escape Studios
#

include_recipe 'newrelic::repository'

license = node['newrelic']['application_monitoring']['license']

# create the directory to install the jar into
directory node['newrelic']['java-agent']['install_dir'] do
  owner node['newrelic']['java-agent']['app_user']
  group node['newrelic']['java-agent']['app_group']
  recursive true
  mode 0775
  action :create
end

remote_file = "#{node['newrelic']['java-agent']['install_dir']}/#{node['newrelic']['java-agent']['jar_file']}"
local_file = "#{node['newrelic']['java-agent']['install_dir']}/newrelic.jar"

remote_file remote_file do
  source node['newrelic']['java-agent']['https_download']
  owner node['newrelic']['java-agent']['app_user']
  group node['newrelic']['java-agent']['app_group']
  path local_file
  mode 0664
  not_if { File.exist?(local_file) }
end

if node['newrelic']['application_monitoring']['appname'].nil?
  node.set['newrelic']['application_monitoring']['appname'] = node['hostname']
end

# configure your New Relic license key
template "#{node['newrelic']['java-agent']['install_dir']}/newrelic.yml" do
  source 'agent/java/newrelic.yml.erb'
  owner node['newrelic']['java-agent']['app_user']
  group node['newrelic']['java-agent']['app_group']
  mode 0644
  variables(
    :license => license,
    :appname => node['newrelic']['application_monitoring']['appname'],
    :logfile => node['newrelic']['application_monitoring']['logfile'],
    :logfile_path => node['newrelic']['application_monitoring']['logfile_path'],
    :loglevel => node['newrelic']['application_monitoring']['loglevel'],
    :audit_mode => node['newrelic']['java-agent']['audit_mode'],
    :log_file_count => node['newrelic']['java-agent']['log_file_count'],
    :log_limit_in_kbytes => node['newrelic']['java-agent']['log_limit_in_kbytes'],
    :log_daily => node['newrelic']['java-agent']['log_daily'],
    :daemon_ssl => node['newrelic']['application_monitoring']['daemon']['ssl'],
    :capture_params => node['newrelic']['application_monitoring']['capture_params'],
    :ignored_params => node['newrelic']['application_monitoring']['ignored_params'],
    :transaction_tracer_enable => node['newrelic']['application_monitoring']['transaction_tracer']['enable'],
    :transaction_tracer_threshold => node['newrelic']['application_monitoring']['transaction_tracer']['threshold'],
    :transaction_tracer_record_sql => node['newrelic']['application_monitoring']['transaction_tracer']['record_sql'],
    :transaction_tracer_stack_trace_threshold => node['newrelic']['application_monitoring']['transaction_tracer']['stack_trace_threshold'],
    :transaction_tracer_slow_sql => node['newrelic']['application_monitoring']['transaction_tracer']['slow_sql'],
    :transaction_tracer_explain_threshold => node['newrelic']['application_monitoring']['transaction_tracer']['explain_threshold'],
    :error_collector_enable => node['newrelic']['application_monitoring']['error_collector']['enable'],
    :browser_monitoring_auto_instrument => node['newrelic']['application_monitoring']['browser_monitoring']['auto_instrument'],
    :cross_application_tracer_enable => node['newrelic']['application_monitoring']['cross_application_tracer']['enable']
  )
  action :create
end

# allow app_group to write to log_file_path
path = node['newrelic']['application_monitoring']['logfile_path']

until path.nil? || path.empty? || path == File::SEPARATOR
  directory path do
    group node['newrelic']['java-agent']['app_group']
    mode 0775
    action :create
  end

  path = File.dirname(path)
end

# execution of the install
execute 'newrelic-install' do
  command "sudo java -jar #{local_file} install"
  only_if { node['newrelic']['java-agent']['execute_install'] }
end
