require 'json'
require 'pathname'

def unindent(string)
  if string.kind_of? String
    indent = string.scan(/^\s*/).min_by{|l|l.length}
    return string.gsub(/^#{indent}/, "")
  end
end

action :create do
  node.run_state[:sensu_definitions] ||= {}

  if new_resource.name.kind_of? String
    pattern = /#{new_resource.name}/
  else
    pattern = new_resource.name
  end

  ruby_block "create definition #{pattern.to_s}" do
    block do 

      definition = { :pattern => pattern, :command => new_resource.command }
      name = definition[:pattern].to_s.gsub(/[^\w]/,'')

      Chef::Log.debug "Creating sensu_spec definition: #{definition[:pattern]}"
      node.run_state[:sensu_definitions][name] = definition

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
