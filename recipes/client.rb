client_data = node.sensu_spec.client.to_hash
Chef::Log.debug "Got client data #{client_data}"
client_data[:name] = node.fqdn
client_data[:address] = node.ipaddress
client_data['subscriptions'] = client_data['subscriptions'] ? client_data['subscriptions'].inject([]) { |a,(k,v)| a << k if v; a } : []

file File.join(node.sensu_spec.conf_dir, "client.json") do
  owner "root"
  group "root"
  mode 0644
  content lazy { JSON.pretty_generate({ :client => client_data }) }
  notifies :restart, 'sensu_service[sensu-client]'
  only_if { node.recipes.include?('sensu::client_service') }
end
