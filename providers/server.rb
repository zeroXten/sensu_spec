action :create do

  node.sensu_spec.checks.each_pair do |check_name, check|
    Chef::Log.debug "Found check #{check_name} with data #{check}"

    check_data = check.to_hash
    check_data['subscribers'] = check_data['subscribers'].inject([]) { |a,(k,v)| a << k if v; a }

    # probably need to add logic here to create granular checks
    %w[ handlers interval ].each do |attr|
      if not check.has_key?(attr)
        Chef::Log.debug "Attribute #{attr} not found for check #{check_name} on client"
        if node.sensu_spec.checks.has_key?(check_name) and node.sensu_spec.checks[check_name].has_key?(attr)
          Chef::Log.debug "Using value from sensu server"
          check_data[attr] = node.sensu_spec.checks[check_name][attr]
        elsif node.sensu_spec.check_defaults.has_key?(attr)
          Chef::Log.debug "Using defaults set in cookbook"
          check_data[attr] = node.sensu_spec.check_defaults[attr]
        else
          Chef::Log.debug "No defaults found, not setting a value"
        end
      else
        Chef::Log.debug "Using value for #{attr} from client check"
      end
    end

    file ::File.join(node.sensu_spec.conf_dir, "#{check_name}.json") do
      owner "root"
      group "root"
      mode 0644
      content lazy { JSON.pretty_generate({ :checks => { check_name => check_data } }) }
      notifies :create, 'ruby_block[sensu_service_trigger]'
    end

  end

=begin
  client = node.sensu_spec.client.to_hash
  client[:name] = node.fqdn
  client[:address] = node.ipaddress
  client['subscriptions'] = client['subscriptions'] ? client['subscriptions'].inject([]) { |a,(k,v)| a << k if v; a } : []
  r = file ::File.join(node.sensu_spec.conf_dir, "#{node.fqdn}.json") do
    owner "root"
    group "root"
    mode 0644
    content JSON.pretty_generate(client)
    action :nothing
  end
  r.run_action(:create)
  new_resource.updated_by_last_action(true) if r.updated_by_last_action?
=end
end

