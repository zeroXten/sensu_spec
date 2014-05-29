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
          Chef::Log.debug "Merging #{new} into #{old}"
          result = Chef::Mixin::DeepMerge.merge(old,new)
          Chef::Log.debug "Result is #{result}"
          node.default.sensu_spec.client = result
        end

        subscriber_name = context.split('.').first
        node.default.sensu_spec.client.subscriptions[subscriber_name] = true
        node.default.sensu_spec.client.subscriptions[node.fqdn] = true

        Chef::Log.debug "Setting spec_command to: #{spec_command}"
        spec_data[check_name] = { :command => spec_command }

        Chef::Log.debug "Setting check_command to #{check_command}"
        node.default.sensu_spec[:checks][check_name][:command] = check_command
        node.default.sensu_spec[:checks][check_name][:subscribers][subscriber_name] = true

      end 

    end
  end

  r = file ::File.join(node.sensu_spec.spec_dir, "#{check_name}.json") do
    owner "root"
    group "root"
    mode 0644
    content JSON.pretty_generate(spec_data)
    action :nothing
  end
  r.run_action(:create)
  new_resource.updated_by_last_action(true) if r.updated_by_last_action?

end

=begin
action :create do

  check_name = new_resource.name.gsub(/[^\w ]/,'').gsub(/[^\w]/,'_')

  check_data = { :checks => {} }

  node.sensu_spec.definitions.each_pair do |definition_name, definition|
    if matches = /^#{definition[:pattern]}$/.match(new_resource.name)
      Chef::Log.debug "Found matching definition for '#{new_resource.name}': #{definition[:pattern]}'"
      if check_data[:checks].has_key?(check_name)
        Chef::Log.warn "Duplicate definition for '#{new_resource.name}'. Ignoring '#{definition[:pattern]}'"
      else
        spec_command = definition[:command]
        matches.names.each do |match|
          spec_command = spec_command.gsub(":::#{match}:::", matches[match])

          old = node.sensu_spec.client.to_hash
          new = match.split('.').reverse.inject(matches[match]) { |a,n| { n => a } }

          Chef::Log.debug "Merging #{new} into #{old}"
          result = Chef::Mixin::DeepMerge.merge(old,new)
          Chef::Log.debug "Result is #{result}"
          node.default[:sensu_spec][:client] = result

        end
        Chef::Log.debug "Setting spec_command to: #{spec_command}"
        check_data[:checks][check_name] = {}
        check_data[:checks][check_name][:command] = spec_command

        tags = new_resource.tags
        Chef::Log.debug "Saving tags #{tags} for definition #{definition_name}"
        
        if node[:sensu_spec][:definitions][definition_name].has_key?(:tags)
          tags = (node[:sensu_spec][:definitions][definition_name][:tags] + tags).uniq
        end
        node.default[:sensu_spec][:definitions][definition_name][:tags] = tags
      end
    end
  end

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
=end






=begin
  name = check_name

  if node['sensu_spec']['checks'].has_key?(name)
    check_data = { 'checks' => { name => node['sensu_spec']['checks'][name] } }
    check_data.delete('enabled')
    node.set['sensu_spec']['checks'][name]['enabled'] = true
  else
    # TODO Ensure command was given
    check_data = { 'checks' => {} }
    check_data['checks'][name] = {}
    check_data['checks'][name]['interval'] = new_resource.interval
    check_data['checks'][name]['handlers'] = new_resource.handlers
    check_data['checks'][name]['subscribers'] = new_resource.subscribers

    if (Pathname.new new_resource.command).absolute?
      check_data['checks'][name]['command'] = new_resource.command
    else
      check_data['checks'][name]['command'] = ::File.join(node['sensu_spec']['default_command_path'], new_resource.command)
    end

  end

  resource = file file_from_spec do
    owner "root"
    group "root"
    mode 0644
    content JSON.pretty_generate(check_data)
    action :nothing
  end
  resource.run_action(:create)

  new_resource.updated_by_last_action(true) if resource.updated_by_last_action?
=end


=begin
action :delete do
  resource = file file_from_spec do
    action :nothing
  end

  resource.run_action(:delete)
  new_resource.updated_by_last_action(true) if resource.updated_by_last_action?
end

def file_from_spec
  ::File.join(node['sensu_spec']['conf_dir'], "#{check_name}.json")
end

def check_name
  new_resource.name.gsub(/[^\w]+/,'_')
end
=end
