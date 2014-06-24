include_recipe "sensu_spec::base"
include_recipe "sensu_spec::definitions"

client_data = node.sensu_spec.client.to_hash
Chef::Log.debug "Got client data #{client_data}"
client_data[:name] = node.attribute?(:fqdn) ? node.fqdn : node.name
client_data[:address] = node.ipaddress
client_data['subscriptions'] = client_data['subscriptions'] ? client_data['subscriptions'].inject([]) { |a,(k,v)| a << k if v; a } : []

case node['platform_family']
when 'debian'
  include_recipe 'apt'
when 'rhel'
  include_recipe 'yum-epel'
  if node['languages']['python']['version'] =~ /^2\.6/
    package 'python-argparse'
  end
end

cookbook_file "/usr/bin/sensu_spec" do
  owner "root"
  group "root"
  mode 0755
end

include_recipe 'sensu_spec::_helper'

file File.join(node.sensu_spec.conf_dir, "client.json") do
  owner "root"
  group "root"
  mode 0644
  content lazy { JSON.pretty_generate({ :client => client_data }) }
  notifies :create, 'ruby_block[sensu_service_trigger]'
end
