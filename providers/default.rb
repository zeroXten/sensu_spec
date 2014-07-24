require 'json'
require 'pathname'


action :create do
  name = new_resource.name # e.g. 'must have 1 java process with args logstash/server'
  context = new_resource.context # e.g. 'logstash_server.process'
  Chef::Log.debug "Processing spec for '#{name}' in context #{context}" 

  check_name = "check_#{context.gsub(/\./,'_')}"

  check_data = {}
  node.run_state[:sensu_client] ||= {}
  node.run_state[:sensu_checks] ||= {}
  node.run_state[:sensu_definitions] ||= {}

  definition_found = false

  node.run_state[:sensu_definitions].each_pair do |definition_name, definition|
    if matches = /^#{definition[:pattern]}$/.match(name)
      definition_found = true
      Chef::Log.debug "Found matching definition for '#{name}': #{definition[:pattern]}' with command '#{definition[:command]}'"

      spec_command = check_command = definition[:command]
      matches.names.each do |match_name|
        full_match_name = "#{context}.#{match_name}"
        check_command = check_command.gsub(":::#{match_name}:::", ":::#{full_match_name}:::")
        
        old = node.run_state.to_hash[:sensu_client]
        new = full_match_name.split('.').reverse.inject(matches[match_name]) { |a,n| { n => a } }
        result = Chef::Mixin::DeepMerge.deep_merge!(new,old)
        Chef::Log.debug "Merged matches. New client state is #{result}"
        node.run_state[:sensu_client] = result
      end

      Chef::Log.debug "Setting check_command to: #{check_command}"
      check_data[:command] = check_command
      check_data[:standalone] = true

      # probably need to add logic here to create granular checks
      node.sensu_spec.check_defaults.keys.each do |attr|
        if not check_data.has_key?(attr)
          Chef::Log.debug "Using defaults set in cookbook"
          check_data[attr] = node.sensu_spec.check_defaults[attr]
        else
          Chef::Log.debug "Using value for #{attr} from client check"
        end
      end

    end
  end

  node.run_state[:sensu_checks][check_name] = check_data
end

