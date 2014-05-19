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

cookbook_file "/usr/bin/sensu_spec" do
  owner "root"
  group "root"
  mode 0755
end

cookbook_file File.join(node['sensu_spec']['nagios']['plugins_path'], 'check_cmd') do
  owner "root"
  group "root"
  mode 0755
end
