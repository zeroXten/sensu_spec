include_recipe 'sensu_spec::base'
include_recipe 'sensu_spec::definitions'
include_recipe 'sensu_spec::_helper'

if Chef::Config[:solo]
  sensu_spec_server 'server'
else
  search(:node, 'name:*').each do |client|
    
    if client.sensu_spec.checks
      client.sensu_spec.checks.each_pair do |check_name, check|
        Chef::Log.debug "Found check #{check_name}"

        check_data = check.to_hash
        check_data['subscribers'] = check_data['subscribers'].inject([]) { |a,(k,v)| a << k if v; a }

        # probably need to add logic here to create granular checks
        node.sensu_spec.check_defaults.keys.each do |attr|
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

        file File.join(node.sensu_spec.conf_dir, "#{check_name}.json") do
          owner "root"
          group "root"
          mode 0644
          content lazy { JSON.pretty_generate({ :checks => { check_name => check_data } }) }
          notifies :restart, 'sensu_service[sensu-server]'
          notifies :restart, 'sensu_service[sensu-api]'
          only_if { node.recipes.include?('sensu::server_service') }
        end
      end

    end rescue NoMethodError
  end
end

client_data = node.sensu_spec.client.to_hash
client_data[:name] = node.attribute?(:fqdn) ? node.fqdn : node.name
client_data[:address] = node.ipaddress
client_data['subscriptions'] = client_data['subscriptions'] ? client_data['subscriptions'].inject([]) { |a,(k,v)| a << k if v; a } : []


file File.join(node.sensu_spec.conf_dir, "client.json") do
  owner "root"
  group "root"
  mode 0644
  content { JSON.pretty_generate({ :client => client_data }) }
  notifies :create, 'ruby_block[sensu_service_trigger]'
end
