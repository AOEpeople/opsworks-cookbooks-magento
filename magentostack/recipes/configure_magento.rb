
node[:deploy].each do |application, deploy|

  ruby_block "Create dynamic Magento configuration file for #{application}" do
    block do
      if deploy.key?(:environment_name) then
        File.open("/tmp/settings_#{application}.csv", 'w') { |file|
          file.write("Handler,Param2,Param2,Param3,#{deploy[:environment_name]}\n")

          if deploy[:database]
            file.write("# Database,,,\n")
            file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/resources/default_setup/connection/dbname,,#{deploy[:database][:database]}\n")
            file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/resources/default_setup/connection/host,,#{deploy[:database][:host]}\n")
            file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/resources/default_setup/connection/password,,#{deploy[:database][:password]}\n")
            file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/resources/default_setup/connection/username,,#{deploy[:database][:username]}\n")
          end

          print "\n\n" + deploy.inspect + "\n\n"

          # Assuming we have a single Redis server
          if node[:opsworks][:layers][:redis][:instances].first
            redis_ip = node[:opsworks][:layers][:redis][:instances].first[1][:private_ip].to_s
            if deploy.key?(:settings) && deploy[:settings].key?(:redis_cache_port)
              file.write("# Cache Backend,,,\n")
              file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/cache/backend_options/server,,#{redis_ip}\n")
              file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/cache/backend_options/port,,#{deploy[:settings][:redis_cache_port].to_s}\n")
            end
            if deploy.key?(:settings) && deploy[:settings].key?(:redis_session_port)
              file.write("# Sessions Storage,,,\n")
              file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/redis_session/host,,#{redis_ip}\n")
              file.write("Est_Handler_XmlFile,app/etc/local.xml,/config/global/redis_session/port,,#{deploy[:settings][:redis_session_port]}\n")
            end
          end
        }
      end
    end
  end

  execute "Apply dynamic Magento environment settings to #{application}" do
    user "deploy"
    cwd "#{deploy[:deploy_to]}/current/#{deploy[:document_root]}"
    command "../tools/apply.php '#{deploy[:environment_name]}' '/tmp/settings_#{application}.csv'"
    action :run
    only_if do deploy.key?(:environment_name) && File.exists?("#{deploy[:deploy_to]}/current/#{deploy[:document_root]}/index.php") end
  end

end
