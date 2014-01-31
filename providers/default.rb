require 'json'
require 'pathname'

action :create do
  name = clean_name

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

  resource = file file_from_spec do
    owner "root"
    group "root"
    mode 0644
    content JSON.pretty_generate(check_data)
    action :nothing
  end
  resource.run_action(:create)
  new_resource.updated_by_last_action(true) if resource.updated_by_last_action?
end

action :delete do
  resource = file file_from_spec do
    action :nothing
  end

  resource.run_action(:delete)
  new_resource.updated_by_last_action(true) if resource.updated_by_last_action?
end

def file_from_spec
  ::File.join(node['sensu_spec']['conf_dir'], "#{clean_name}.json")
end

def clean_name
  new_resource.name.gsub(/[^\w]+/,'_')
end
