Chef::Log.debug "Creating required sensu directories"
%w[ conf_dir plugin_dir ].each do |dir|
  directory node['sensu_spec'][dir] do
    owner "root"
    group "root"
    mode 0755
    recursive true
  end
end
