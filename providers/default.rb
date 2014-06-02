require 'json'
require 'pathname'


action :create do
  name = new_resource.name # e.g. 'must have 1 java process with args logstash/server'
  context = new_resource.context # e.g. 'logstash_server.process'

  check_name = "check_#{context.gsub(/\./,'_')}"

  spec_data = {}

  node.sensu_spec.definitions.each_pair do |definition_name, definition|
    if matches = /^#{definition[:pattern]}$/.match(name)
      Chef::Log.debug "Found matching definition for '#{name}': #{definition[:pattern]}' with command '#{definition[:command]}'"
      if spec_data.has_key?(check_name)
        Chef::Log.warn "Duplicate definition for '#{name}'. Ignoring '#{definition[:pattern]}'"
      else
        spec_command = check_command = definition[:command]
        matches.names.each do |match_name|
          spec_command = spec_command.gsub(":::#{match_name}:::", matches[match_name])

          full_match_name = "#{context}.#{match_name}"
          check_command = check_command.gsub(":::#{match_name}:::", ":::#{full_match_name}:::")

          old = node.sensu_spec.client.to_hash
          new = full_match_name.split('.').reverse.inject(matches[match_name]) { |a,n| { n => a } }
          Chef::Log.debug "Merging #{new} into #{old} (#{old.class})"
          result = Chef::Mixin::DeepMerge.merge(new,old)
          Chef::Log.debug "Result is #{result}"
          node.set.sensu_spec.client = result
          Chef::Log.debug "Node attributes updated"
        end

        subscriber_name = context.split('.').first
        Chef::Log.debug "Adding subscriber #{subscriber_name}"
        node.set.sensu_spec.client.subscriptions[subscriber_name] = true
        Chef::Log.debug "Adding subscriber #{node.fqdn}"
        node.set.sensu_spec.client.subscriptions[node.fqdn] = true

        Chef::Log.debug "Setting spec_command to: #{spec_command}"
        spec_data[check_name] = { :command => spec_command }

        Chef::Log.debug "Setting check_command to #{check_command}"
        node.set.sensu_spec[:checks][check_name][:command] = check_command
        node.set.sensu_spec[:checks][check_name][:subscribers][subscriber_name] = true

      end 

    end
  end

  r = file ::File.join(node.sensu_spec.spec_dir, "#{check_name}.json") do
    owner "root"
    group "root"
    mode 0644
    content JSON.pretty_generate({ :checks => spec_data})
    action :nothing
  end
  r.run_action(:create)
  new_resource.updated_by_last_action(true) if r.updated_by_last_action?

end






