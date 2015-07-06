Chef::Log.info("Recipe magentostack::elb_register")

currentInstanceId = node[:opsworks][:instance][:aws_instance_id]

Chef::Log.info("Current instance Id: #{currentInstanceId}")

if node.key?('additional-elbs') && node['additional-elbs'].key?('elbs')
  node['additional-elbs']['elbs'].each do |elb|
    Chef::Log.info("Elb: #{elb}")
    execute "Register instance #{currentInstanceId} with ELB #{elb}" do
      command "aws --region #{node[:opsworks][:instance][:region]} elb register-instances-with-load-balancer --load-balancer-name #{elb} --instances \"#{node[:opsworks][:instance][:aws_instance_id]}\""
      environment(
        'AWS_ACCESS_KEY_ID' => node['additional-elbs']['aws_access_key_id'],
        'AWS_SECRET_ACCESS_KEY' => node['additional-elbs']['aws_secret_access_key']
      )
      user "deploy"
    end
  end
end