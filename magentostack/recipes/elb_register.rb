Chef::Log.info("Recipe magentostack::elb_register")

currentInstanceId = node[:opsworks][:instance][:aws_instance_id]

Chef::Log.info("Current instance Id: #{currentInstanceId}")

# current instances
#currentIds = node[:opsworks][:layers]['php-app'][:instances].sort.collect{|i| i['aws_instance_id'] }
#Chef::Log.info("Current instance Ids: #{currentIds}")

node['additional-elbs']['elbs'].each do |elb|
  Chef::Log.info("Elb: #{elb}")
end



#"aws_access_key_id"
#"aws_secret_access_key"
