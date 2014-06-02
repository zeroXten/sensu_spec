Chef::Log.debug "Creating required sensu directories"
%w[ conf_dir plugin_dir spec_dir ].each do |dir|
  directory node['sensu_spec'][dir] do
    owner "root"
    group "root"
    mode 0755
    recursive true
  end
end

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

client_data = node.sensu_spec.client.to_hash
client_data[:name] = node.fqdn
client_data[:address] = node.ipaddress
client_data['subscriptions'] = client_data['subscriptions'] ? client_data['subscriptions'].inject([]) { |a,(k,v)| a << k if v; a } : []

file File.join(node.sensu_spec.conf_dir, "client.json") do
  owner "root"
  group "root"
  mode 0644
  content JSON.pretty_generate({ :client => client_data })
end
