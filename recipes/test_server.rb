directory node['sensu_spec']['conf_dir'] do
  owner "root"
  group "root"
  mode 0755
  recursive true
end

include_recipe 'sensu_spec::definitions'
sensu_spec 'has check_cmd'

include_recipe 'sensu_spec::server'
