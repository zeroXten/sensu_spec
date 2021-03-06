
include_recipe 'sensu::_base'
include_recipe "sensu_spec::definitions"

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


client_data = {}
client_data[:name] = node.attribute?(:fqdn) ? node.fqdn : node.name
client_data[:address] = node.ipaddress
client_data[:subscriptions] = node.sensu_spec.client_defaults.subscriptions

node.run_state[:sensu_client] ||= {}
node.run_state[:sensu_checks] ||= {}

client_file = File.join(node.sensu_spec.conf_dir, "client.json")
file client_file do
  owner "root"
  group "root"
  mode 0644
  content lazy { JSON.pretty_generate({ :client => client_data.merge(node.run_state[:sensu_client]) }) }
  action :nothing
  notifies :create, 'ruby_block[sensu_service_trigger]'
end

Chef::Log.debug "SENSU_CHECKS"
Chef::Log.debug node.run_state[:sensu_checks]
checks_file = File.join(node.sensu_spec.conf_dir, "checks.json")
file checks_file do
  owner "root"
  group "root"
  mode 0644
  content lazy { JSON.pretty_generate({ :checks => node.run_state[:sensu_checks] }) }
  action :nothing
  notifies :create, 'ruby_block[sensu_service_trigger]'
end

execute 'dummy exec' do
  command 'true'
  notifies :create, "file[#{client_file}]", :delayed
  notifies :create, "file[#{checks_file}]", :delayed
end
