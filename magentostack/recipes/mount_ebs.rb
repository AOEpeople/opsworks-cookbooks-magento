# see http://docs.aws.amazon.com/opsworks/latest/userguide/workinglayers-basics-edit.html#d0e19597
mount_point = node['ebs_mount_point'] rescue nil

if mount_point
  node[:deploy].each do |application, deploy|
    directory "#{mount_point}/#{application}" do
      owner deploy[:user]
      group deploy[:group]
      mode 0770
      recursive true
    end

    link "/srv/www/#{application}" do
      to "#{mount_point}/#{application}"
    end
  end
end