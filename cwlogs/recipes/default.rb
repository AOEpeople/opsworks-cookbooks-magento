if node['ec2'].nil?
  log('Refusing to install CloudWatch Logs because this does not appear to be an EC2 instance.') { level :warn }
  return
end

if node['cwlogs']['logfiles'].nil?
  log("Refusing to install CloudWatch Logs because no logs have been configured. (node['cwlogs']['logfiles'] is nil)") { level :warn }
  return
end

if node[:platform] == 'amazon' && Gem::Version.new(node['platform_version']) >= Gem::Version.new('2014.09')
  include_recipe 'cwlogs::package'
else
  include_recipe 'cwlogs::installer'
end
