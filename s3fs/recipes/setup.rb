#
# Copyright (C) 2014 NetSrv Consulting Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# see: https://github.com/s3fs-fuse/s3fs-fuse/wiki/Installation-Notes#tested-on-ubuntu-1404-lts
%w(build-essential git libfuse-dev libcurl4-openssl-dev libxml2-dev mime-support automake libtool).each do |pkg|
  package pkg do
    action :install
  end
end
  
s3fs_distribution = '/usr/src/s3fs.tar.gz'

remote_file s3fs_distribution do
  action :create_if_missing
  source node[:s3fs][:download]
end

bash 'build s3fs' do
  action :run
  code <<-EOH
    tmpdir="$(mktemp -d)"
    cd $tmpdir
    tar xzf #{s3fs_distribution} --strip-components=1
    ./autogen.sh
    ./configure --prefix=/usr --with-openssl
    make
    make install
  EOH
  not_if 'which s3fs'
end

s3fs_passwd_content = []

buckets = node[:s3fs].attribute?(:buckets) ? node[:s3fs][:buckets] : []

begin
  buckets.each do |bucket|
    bucket_name = bucket[:name]
    access_key  = bucket[:access_key]
    secret_key  = bucket[:secret_key]
    
    if bucket_name.empty? || access_key.empty? || secret_key.empty?
      bucket_name ||= 'not configured'
      fail "Invalid S3FS bucket configuration for bucket name: #{bucket_name}"
    end
    
    Chef::Log.info("Found S3FS bucket configuration for #{bucket_name}")
    
    s3fs_passwd_content << "#{bucket_name}:#{access_key}:#{secret_key}"
  end
rescue
  raise 'Invalid bucket configuration.
    Please specify name, accessKey and secretKey.'
end

file '/etc/passwd-s3fs' do
  action :create
  content s3fs_passwd_content.join("\n")
  owner 'root'
  group 'root'
  mode 0600
  not_if { s3fs_passwd_content.empty? }
end

# Mount the buckets
buckets.each do |bucket|
  
  directory "/mnt/#{bucket[:name]}"

  # Folders will be created in here for each of the buckets by s3fs
  cache_dir = '/media/ephemeral0/s3fs'
  
  # Give a reminder as filling up the root volume would be bad
  Chef::Log.info("Enabling S3FS caching on #{cache_dir}")
    
  directory cache_dir do
    action :create
    recursive true
  end

  execute "umount /mnt/#{bucket[:name]}" do
    only_if %Q(mount | grep "s3fs on /mnt/#{bucket[:name]}")
    notifies :write, 'log[unmounting s3fs bucket]', :immediately
  end
  
  log('unmounting s3fs bucket') do
    message "Unmounting existing S3FS mount at /mnt/#{bucket[:name]}"
    action :nothing
  end
    
  execute "s3fs #{bucket[:name]} /mnt/#{bucket[:name]} -o allow_other -o use_cache=#{cache_dir}"
end
