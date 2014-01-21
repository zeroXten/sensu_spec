#
# Cookbook Name:: sensu_spec
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

include_recipe "sensu_spec::client"

cookbook_file File.join(node['sensu_spec']['nagios']['plugins_path'], 'check_cmd') do
  owner "root"
  group "root"
  mode 0755
end
