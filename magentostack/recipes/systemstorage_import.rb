# This assumes the Magento install has already been configured with the correct database parameters
# This is a chicken-and-egg problem and requires you to manually import the initial db dump
# and also makes it different to boot up non-master systems fully automatically from scratch

node[:deploy].each do |application, deploy|

  # Chef::Log.info("Variable 'deploy': #{deploy.inspect}")
  # Chef::Log.info("Variable 'application': #{application.inspect}")

  if deploy.key?(:systemstorage)
    master_system = IO.read("#{deploy[:deploy_to]}/current/Configuration/mastersystem.txt").strip
    Chef::Log.info("Detected master system: #{master_system}")
    Chef::Log.info("Current environment: #{deploy[:environment_name]}")

    access_key = deploy[:systemstorage][:access_key]
    secret_key = deploy[:systemstorage][:secrect_key]
    region = deploy[:systemstorage][:region]
    s3_location = deploy[:systemstorage][:s3_location].sub(/(\/)+$/,'') 
    profile_name = application

    if master_system != deploy[:environment_name]

      execute "Configure aws cli tool" do
        user "deploy"
        command "aws configure set aws_access_key_id '#{access_key}' --profile '#{profile_name}'; aws configure set aws_secret_access_key '#{secret_key}' --profile '#{profile_name}'; aws configure set region '#{region}' --profile '#{profile_name}'"
        action :run
      end

      tmpdir = Dir.mktmpdir("systemstorage-for-#{deploy[:environment_name]}")
      directory tmpdir do
        mode 0775
        owner "deploy"
        group "deploy"
      end

      remote_location = s3_location + "/" + master_system
      Chef::Log.info("Remote bucket location: #{remote_location}")

      execute "Download systemstorage for master instance '#{master_system}'" do
        user "deploy"
        command "aws --profile '#{profile_name}' s3 cp --recursive #{remote_location} #{tmpdir}"
        action :run
      end

      execute "Import systemstorage" do
        user "deploy"
        command "#{deploy[:deploy_to]}/current/tools/systemstorage_import.sh -p #{deploy[:deploy_to]}/current/htdocs -s #{tmpdir}"
        action :run
      end

=begin
      execute "Fix permissions on shared folder" do
        user "root"
        command "chmod -R ug+rw #{shared_folder}; chown -R deploy:www-data #{shared_folder}"
        action :run
        not_if { "#{master_system}" == "#{environment_name}" }
      end
=end

      directory tmpdir do
        action :delete
        recursive true
      end
    end
  end
end