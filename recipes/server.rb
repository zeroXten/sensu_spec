
if Chef::Config[:solo]
  sensu_spec_server 'server'
else
  search(:node, 'name:*').each do |client|

    client.sensu_spec.checks.each_pair do |check_name, check|
      Chef::Log.debug "Found check #{check_name}"

      check_data = check.to_hash
      check_data['subscribers'] = check_data['subscribers'].inject([]) { |a,(k,v)| a << k if v; a }

      file File.join(node.sensu_spec.conf_dir, "#{check_name}.json") do
        owner "root"
        group "root"
        mode 0644
        content JSON.pretty_generate(check_data)
        action :create_if_missing # defensive for now. Not sure what to do if things clash.
      end
    end

    client_data = client.sensu_spec.client.to_hash
    client_data[:name] = client.fqdn
    client_data[:address] = client.ipaddress
    client_data['subscriptions'] = client_data['subscriptions'] ? client_data['subscriptions'].inject([]) { |a,(k,v)| a << k if v; a } : []

    file File.join(node.sensu_spec.conf_dir, "#{node.fqdn}.json") do
      owner "root"
      group "root"
      mode 0644
      content JSON.pretty_generate(client_data)
    end

  end
end

=begin
if Chef::Config[:solo]
  sensu_spec_server 'server'
else

  checks = {}

  search(:node, 'name:*').each do |client|
    if client.has_key?('sensu_spec') and client['sensu_spec'].has_key?('checks') and (client['sensu_spec']['checks'].kind_of?(Hash) or client['sensu_spec']['checks'].kind_of?(Mash))
      client['sensu_spec']['checks'].each_pair do |name, check_data|
        if check_data['enabled']

          Chef::Log.warn("Duplicate sensu check definition found for #{name}. Not replacing") if checks.has_key?(name)
          check_data.delete('enabled')
          checks[name] = check_data 
        end
      end
    end
  end

  checks.each_pair do |name, check_data|
    file ::File.join(node['sensu_spec']['conf_dir'], "#{name}.json") do
      owner "root"
      group "root"
      mode 0644
      content JSON.pretty_generate(check_data)
    end
  end

end
=end
