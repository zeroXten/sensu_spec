%w[ conf_dir plugin_dir spec_dir ].each do |dir|
  directory node['sensu_spec'][dir] do
    owner "root"
    group "root"
    mode 0755
    recursive true
  end
end

case node['platform_family']
when 'debian'
  include_recipe 'apt'
when 'rhel'
  include_recipe 'yum-epel'
  if node['languages']['python']['version'] =~ /^2\.6/
    package 'python-argparse'
  end
end

cookbook_file "/usr/bin/sensu_spec" do
  owner "root"
  group "root"
  mode 0755
end

include_recipe 'sensu_spec::definitions'
