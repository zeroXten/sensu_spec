client_data = node.sensu_spec.client.to_hash
Chef::Log.debug "Got client data #{client_data}"
client_data[:name] = node.attribute?(:fqdn) ? node.fqdn : node.name
client_data[:address] = node.ipaddress
client_data['subscriptions'] = client_data['subscriptions'] ? client_data['subscriptions'].inject([]) { |a,(k,v)| a << k if v; a } : []

unless run_context.resource_collection.include?('ruby_block[sensu_service_trigger]')
  ruby_block 'sensu_service_trigger' do
    block do 
      Chef::Log.debug "Dummy sensu_service_trigger"
    end
    action :nothing
  end
end

file File.join(node.sensu_spec.conf_dir, "client.json") do
  owner "root"
  group "root"
  mode 0644
  content lazy { JSON.pretty_generate({ :client => client_data }) }
  notifies :create, 'ruby_block[sensu_service_trigger]'
end
