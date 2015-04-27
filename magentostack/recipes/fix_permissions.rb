
node[:deploy].each do |application, deploy|

  app_basepath="#{deploy[:deploy_to]}/current/"
	
  execute "Change owner for #{application}" do
    user "root"
    command "chown -R #{node[:apache][:user]}:#{node[:apache][:user]} #{app_basepath}"
    action :run
  end
  
  execute "Change project file permissions for #{application}" do
    user "root"
    command "find #{app_basepath} -type f -exec chmod 400 {} \\;"
    action :run
  end
  
  execute "Change project directory permissions for #{application}" do
    user "root"
    command "find #{app_basepath} -type d -exec chmod 500 {} \\;"
    action :run
  end
	
  %w(media var).each do |name|
    execute "Change project file permissions for #{app_basepath}/../shared/#{name}" do
      user "root"
      command "find #{app_basepath}/../shared/#{name} -type f -exec chmod 600 {} \\;"
      action :run
    end
  
    execute "Change project directory permissions for #{app_basepath}/../shared/#{name}" do
      user "root"
      command "find #{app_basepath}/../shared/#{name} -type d -exec chmod 700 {} \\;"
      action :run
    end
  end

end
