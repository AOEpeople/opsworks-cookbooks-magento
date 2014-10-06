package 'unzip' do
  action :upgrade
end

remote_file "#{Chef::Config[:file_cache_path]}/awscli-bundle.zip" do
  source 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip'
  not_if 'test -e /usr/local/bin/aws'
  notifies :run, 'execute[install awscli]', :immediately
end

execute 'install awscli' do
  command 'unzip awscli-bundle.zip; ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws'
  user 'root'
  cwd Chef::Config[:file_cache_path]
  action :nothing
end

