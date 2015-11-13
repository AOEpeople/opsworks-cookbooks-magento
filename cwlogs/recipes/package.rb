package 'awslogs' do
  action :install
end

directory node['cwlogs']['state_file_dir'] do
  owner 'root'
  group 'root'
  mode 0755
  recursive true
  action :create
end

template '/etc/awslogs/awscli.conf' do
  source 'awscli.conf.erb'
  owner 'root'
  group 'root'
  mode 0600
end

template '/etc/awslogs/awslogs.conf' do
  source "awslogs.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables ({
    :logfiles => node['cwlogs']['logfiles']
  })
  notifies :restart, 'service[awslogs]'
end

service 'awslogs' do
  supports [:start, :stop, :status, :restart]
  action [:enable, :start]
end
