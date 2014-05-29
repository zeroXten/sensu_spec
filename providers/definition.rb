require 'json'
require 'pathname'

def unindent(string)
  if string.kind_of? String
    indent = string.scan(/^\s*/).min_by{|l|l.length}
    return string.gsub(/^#{indent}/, "")
  end
end

action :create do
  ruby_block "create definition #{new_resource.name}" do
    block do 

      definition = { :pattern => new_resource.name, :command => new_resource.command }
      name = definition[:pattern].to_s.gsub(/[^\w]/,'')

      Chef::Log.debug "Creating sensu_spec definition: #{definition[:pattern]}"
      node.default.sensu_spec.definitions[name] = definition

    end
  end

  Chef::Log.debug "Found code for definition"
  r = file ::File.join(node.sensu_spec.plugin_dir, new_resource.command.split.first) do
    owner "root"
    group "root"
    mode 0755
    content unindent(new_resource.code)
    action :nothing
    only_if { new_resource.code }
  end
  r.run_action(:create)
  new_resource.updated_by_last_action(true) if r.updated_by_last_action?
end
=begin
      name = clean_name

      check_data = { 'checks' => { name => { 'enabled' => false } } }

      %w[ subscribers interval handlers handle subdue dependencies type standalone publish occurrences refresh low_flap_threshold high_flap_threshold aggregate handler ].each do |attr|
        if new_resource.send(attr)
          check_data['checks'][name][attr] = new_resource.send(attr)
        elsif node['sensu_spec']['checks'].has_key?(name) and node['sensu_spec']['checks'][name].has_key?(attr)
          check_data['checks'][name][attr] = node['sensu_spec']['checks'][name][attr]
        elsif node['sensu_spec']['checks_default'].has_key?(attr)
          check_data['checks'][name][attr] = node['sensu_spec']['checks_default'][attr]
        end
      end

      if (Pathname.new new_resource.command).absolute?
        check_data['checks'][name]['command'] = new_resource.command
      else
        check_data['checks'][name]['command'] = ::File.join(node['sensu_spec']['default_command_path'], new_resource.command)
      end

      node.set['sensu_spec']['checks'][name] = check_data['checks'][name]

=end

=begin
action :delete do
  resource = file file_from_spec do
    action :nothing
  end
end
=end
