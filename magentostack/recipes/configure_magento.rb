
node[:deploy].each do |application, deploy|

  # Chef::Log.info("Variable 'deploy': #{deploy.inspect}")
  # Chef::Log.info("Variable 'application': #{application.inspect}")
  
  ruby_block "Create dynamic Magento configuration file for #{application}" do
    only_if do deploy.key?(:application) end
    block do
      File.open("/tmp/settings_#{application}.csv", 'w') { |file|
        file.write("Handler,Param2,Param2,Param3,#{deploy[:environment_name]}\n")

        if deploy[:database] && deploy[:database].key?(:database) && deploy[:database][:database]
          file.write("# Database,,,\n")
          file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/resources/default_setup/connection/dbname,,#{deploy[:database][:database]}\n")
          file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/resources/default_setup/connection/host,,#{deploy[:database][:host]}\n")
          file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/resources/default_setup/connection/password,,#{deploy[:database][:password]}\n")
          file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/resources/default_setup/connection/username,,#{deploy[:database][:username]}\n")
        end

        print "\n\n" + deploy.inspect + "\n\n"

        # Assuming we have a single Redis server
        if node[:opsworks][:layers].key?(:redis) && node[:opsworks][:layers][:redis][:instances].first
          redis_ip = node[:opsworks][:layers][:redis][:instances].first[1][:private_ip].to_s
          if deploy.key?(:settings) && deploy[:settings].key?(:redis_cache_port)
            file.write("# Cache Backend,,,\n")
            file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/cache/backend,,Cm_Cache_Backend_Redis\n")
            file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/cache/backend_options/server,,#{redis_ip}\n")
            file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/cache/backend_options/port,,#{deploy[:settings][:redis_cache_port].to_s}\n")
            file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/cache/backend_options/database,,0\n")
          end
          if deploy.key?(:settings) && deploy[:settings].key?(:redis_session_port)
            file.write("# Sessions Storage,,,\n")
            file.write("Est_Handler_XmlFile,app/etc/modules/Cm_RedisSession.xml,/config/modules/Cm_RedisSession/active,,true\n")
            file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/session_save,,db\n")
            file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/redis_session/host,,#{redis_ip}\n")
            file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/redis_session/port,,#{deploy[:settings][:redis_session_port]}\n")
          end
        end

        # dynamically add more settings
        if deploy[:env_settings]
          file.write("# Settings added via chef json,,,\n")
          deploy[:env_settings].each do |env_setting|
            file.write("#{env_setting[:handler]},#{env_setting[:param1]},#{env_setting[:param2]},#{env_setting[:param3]},#{env_setting[:value]}\n")
          end
        end

      }
    end
  end

  # magento_basepath="#{deploy[:deploy_to]}/current/#{deploy[:document_root]}/"
  # 'document_root' is not always populated (e.g. when another app is deployed)
  magento_basepath="#{deploy[:deploy_to]}/current/htdocs/"

  execute "Apply dynamic Magento environment settings to #{application}" do
    user "deploy"
    cwd magento_basepath
    command "../tools/apply.php '#{deploy[:environment_name]}' '/tmp/settings_#{application}.csv'"
    action :run
    only_if do deploy.key?(:application) && File.exists?("#{magento_basepath}index.php") end
  end

  Chef::Log.info("#{node[:opsworks][:layers]['php-app'].inspect}")

  if node[:opsworks][:layers]['php-app'][:instances].count > 0

    Chef::Log.info("First server in layer IP: #{node[:opsworks][:layers]['php-app'][:instances].sort.first[1][:private_ip].inspect}")
    Chef::Log.info("This server's IP: #{node[:opsworks][:instance][:private_ip].inspect}")

    masterinstance = (node[:opsworks][:layers]['php-app'][:instances].sort.first[1][:private_ip] == node[:opsworks][:instance][:private_ip])
    Chef::Log.info("Master instance: #{masterinstance.inspect}")
    Chef::Log.info("Magento base path: #{magento_basepath}")

    cron "Magento cron on master instance for #{application}" do
      action masterinstance ? :create : :delete
      minute '*'
      user node[:apache][:user]
      command "! test -e #{magento_basepath}maintenance.flag && test -e #{magento_basepath}cron.sh && bash #{magento_basepath}cron.sh"
    end

  end

end
