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

=begin
action :create do
  
  checks = {}
  
  client = { 
    :client => {
      :name => node.fqdn,
      :address => node.ipaddress,
      :subscriptions => []
    }
  }

  node.sensu_spec.definitions.each_pair do |definition_name, definition|
    Chef::Log.debug "Found definition #{definition_name} with pattern:  #{definition[:pattern]}"
    unique_on = definition[:unique_on]
    Chef::Log.debug "Getting value for #{unique_on}"

    begin
      value = unique_on.split('.').inject(node.sensu_spec.client) { |h,e| h[e.to_sym] }
      Chef::Log.debug "Found #{value}"
      name = "check_#{unique_on}_#{value}"
    rescue
      Chef::Log.debug "Not found, skipping definition as not used"
      next
    end

    command = definition[:command].gsub(":::#{unique_on}:::", value)
    checks[name] = { :command => command }

    %w[ subscribers interval handlers handle subdue dependencies type standalone publish occurrences refresh low_flap_threshold high_flap_threshold aggregate handler ].each do |attr|
      checks[name][attr] = definition[attr] if definition.has_key?(attr)
    end

    checks[name]['subscribers'] ||= []
    checks[name]['subscribers'].push(*definition[:tags]).uniq!

    client[:client][:subscriptions].push(*definition[:tags]).uniq!
  end

  checks.each_pair do |name,check_data|
    r = file ::File.join(node.sensu_spec.conf_dir, "#{name}.json") do
      owner "root"
      group "root"
      mode 0644
      content JSON.pretty_generate(check_data)
      action :nothing
    end
    r.run_action(:create)
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end

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
=begin
  node.sensu_spec.checks.each_pair do |name, check_data|
    r = sensu_spec name do
      action :nothing
      #only_if { check_data['enabled'] }
    end
    r.run_action(:create)
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end
=end
=begin
end
=end
