include_recipe "deploy"
include_recipe "apache2::service"

execute "anki restart apache" do
  command "echo 'Restarting Apache now'"
  action :run
  notifies :restart, "service[apache2]"
end


