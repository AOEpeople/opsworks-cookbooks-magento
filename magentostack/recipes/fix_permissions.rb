
node[:deploy].each do |application, deploy|

  app_basepath="#{deploy[:deploy_to]}/current/"
  shared_basepath="/srv/www/#{application}/shared/"

  execute "Change owner for #{application}" do
    user "root"
    command "chown -R #{node[:apache][:user]}:#{node[:apache][:user]} #{app_basepath}"
    action :run
  end
  
  execute "Making tools executable in #{app_basepath}tools" do
    user "root"
    command "find -L #{app_basepath}tools -type f -exec chmod 775 {} \\;"
    action :run
  end
  
  execute "Change project file permissions for #{application}" do
    user "root"
    command "find #{app_basepath} -type f -exec chmod 664 {} \\;"
    action :run
  end
  
  execute "Change project directory permissions for #{application}" do
    user "root"
    command "find #{app_basepath} -type d -exec chmod 775 {} \\;"
    action :run
  end

  %w(media var).each do |name|
    execute "Change owner for #{shared_basepath}#{name}" do
      user "root"
      command "chown -R #{node[:apache][:user]}:#{node[:apache][:user]} #{shared_basepath}#{name}"
      action :run
    end
    execute "Change project file permissions for #{shared_basepath}#{name}" do
      user "root"
      command "find #{shared_basepath}#{name} -type f -exec chmod 664 {} \\;"
      action :run
    end
    execute "Change project directory permissions for #{shared_basepath}#{name}" do
      user "root"
      command "find #{shared_basepath}#{name} -type d -exec chmod 775 {} \\;"
      action :run
    end
  end
 
end