action :create do

  node['sensu_spec']['checks'].each_pair do |name, check_data|
    r = sensu_spec name do
      action :nothing
      only_if { check_data['enabled'] }
    end
    r.run_action(:create)
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end

end

action :delete do
  pass
end
