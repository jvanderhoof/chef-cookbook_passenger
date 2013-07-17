#
# Cookbook Name:: passenger
# Recipe:: mod_rails
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Joshua Sierles (<joshua@37signals.com>)
# Author:: Michael Hale (<mikehale@gmail.com>)
# Author:: Mike Adolphs (<mike@fooforge.com)
#
# Copyright:: 2009, Opscode, Inc
# Copyright:: 2009, 37signals
# Coprighty:: 2009, Michael Hale
# Copyright:: 2012, Mike Adolphs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "passenger"

if platform?("ubuntu","debian")
  template "#{node[:apache][:dir]}/mods-available/passenger.load" do
    cookbook "passenger"
    source "passenger.load.erb"
    owner "root"
    group "root"
    mode 0755
  end
end

template "#{node[:apache][:dir]}/mods-available/passenger.conf" do
  cookbook "passenger"
  source "passenger.conf.erb"
  owner "root"
  group "root"
  mode "644"
end

unless node[:passenger][:rbenv][:enabled]
  apache_module "passenger" do
    module_path node[:passenger][:module_path]
  end
else
  apache_module "passenger" do
    module_path node[:passenger][:rbenv][:module_path]
  end
end

unless node[:passenger][:web_app].nil?
  node[:passenger][:web_app].each do |app|
    web_app app[:name] do
      docroot app[:docroot]
      server_name app[:server_name]
      server_aliases ([app[:name],node[:hostname]]+[*app[:server_aliases]]).uniq.compact
      rails_env app[:rails_env]
    end
  end
end

node[:passenger][:rack_app].each do |app|
  rack_app app[:name] do
    docroot app[:docroot]
    server_name app[:server_name]
  end
end

=begin
web_app "myproj" do
  docroot "/var/www/public"
  server_name "myproj.#{node[:domain]}"
  server_aliases [ "myproj", node[:hostname] ]
  rails_env "production"
end
=end