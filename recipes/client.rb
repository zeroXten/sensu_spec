case node['platform_family']
when 'debian'
  include_recipe 'apt'
when 'rhel'
  include_recipe 'yum-epel'
  if node['languages']['python']['version'] =~ /^2\.6/
    package 'python-argparse'
  end
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

cookbook_file "/usr/bin/sensu_spec" do
  owner "root"
  group "root"
  mode 0755
end

