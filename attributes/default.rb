default['sensu_spec']['conf_dir'] = '/etc/sensu/conf.d'
default['sensu_spec']['checks'] = []
default['sensu_spec']['nagios']['plugins_path'] = '/usr/lib/nagios/plugins/'

case node['platform_family']
when 'rhel'
  default['sensu_spec']['nagios']['packages'] = [ 'nagios-plugins-all' ]
  if node['kernel']['machine'] == 'x86_64'
    default['sensu_spec']['nagios']['plugins_path'] = '/usr/lib64/nagios/plugins/'
  end
when 'debian'
  default['sensu_spec']['nagios']['packages'] = [ 'nagios-plugins' ]
end

default['sensu_spec']['default_command_path'] = default['sensu_spec']['nagios']['plugins_path']
default['sensu_spec']['retry_count'] = 0
default['sensu_spec']['retry_sleep'] = 1.0
