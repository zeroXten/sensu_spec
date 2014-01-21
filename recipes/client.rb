case node['platform_family']
when 'debian'
  include_recipe 'apt'
when 'rhel'
  include_recipe 'yum-epel'
end

directory node['sensu_spec']['conf_dir'] do
  owner "root"
  group "root"
  mode 0755
  recursive true
end

node['sensu_spec']['nagios']['packages'].each do |pkg|
  package pkg
end

sensu_spec "check procs" do
  command "check_procs"
end

cookbook_file "/usr/local/bin/sensu_spec_run.py" do
  owner "root"
  group "root"
  mode 0755
end

