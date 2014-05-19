require 'json'
require 'pathname'

action :create do
  ruby_block "create definition #{new_resource.name}" do
    block do 
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
    end
  end
end

action :delete do
  resource = file file_from_spec do
    action :nothing
  end
end

def clean_name
  new_resource.name.gsub(/[^\w]+/,'_')
end
