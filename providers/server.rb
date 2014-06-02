action :create do

  node.sensu_spec.checks.each_pair do |check_name, check|
    Chef::Log.debug "Found check #{check_name}"

    check_data = check.to_hash
    check_data['subscribers'] = check_data['subscribers'].inject([]) { |a,(k,v)| a << k if v; a }

    r = file ::File.join(node.sensu_spec.conf_dir, "#{check_name}.json") do
      owner "root"
      group "root"
      mode 0644
      content JSON.pretty_generate(check_data)
      action :nothing
    end
    r.run_action(:create)
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?

  end

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

end

