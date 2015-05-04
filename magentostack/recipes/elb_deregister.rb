Chef::Log.info("Recipe magentostack::elb_deregister")

currentInstanceId = node[:opsworks][:instance][:aws_instance_id]

Chef::Log.info("Current instance Id: #{currentInstanceId}")

node['additional-elbs']['elbs'].each do |elb|
  Chef::Log.info("Elb: #{elb}")

  execute "Register instance #{currentInstanceId} with ELB #{elb}" do
    command "AWS_ACCESS_KEY_ID=\"#{node['additional-elbs']['aws_access_key_id']}\"; AWS_SECRET_ACCESS_KEY=\"#{node['additional-elbs']['aws_secret_access_key']}\"; aws --region #{node[:opsworks][:instance][:region]} elb deregister-instances-from-load-balancer --load-balancer-name #{elb} --instances '{\"instance_id\":\"#{node[:opsworks][:instance][:aws_instance_id]}\"}'"
    user "deploy"
  end

end
