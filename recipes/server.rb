if Chef::Config[:solo]
  sensu_spec_server 'server'
else

  checks = {}

  search(:node, 'name:*').each do |client|
    if client.has_key?('sensu_spec')
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

