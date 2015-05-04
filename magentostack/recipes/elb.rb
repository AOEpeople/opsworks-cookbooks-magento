Chef::Log.info("Recipe magentostack::elb")

# current instances
currentIds = node[:opsworks][:layers]['php-app'][:instances].sort.collect{|i| i['aws_instance_id'] }
Chef::Log.info("Current instance Ids: #{currentIds}")