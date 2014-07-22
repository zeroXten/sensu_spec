default['sensu_spec']['conf_dir'] = '/etc/sensu/conf.d'
default['sensu_spec']['plugin_dir'] = '/etc/sensu/plugins'
default['sensu_spec']['nagios']['plugins_path'] = '/usr/lib/nagios/plugins/'

default['sensu_spec']['default_command_path'] = default['sensu_spec']['nagios']['plugins_path']
default['sensu_spec']['retry_count'] = 0
default['sensu_spec']['retry_sleep'] = 1.0

default.sensu_spec.check_defaults.handlers = ['default']
default.sensu_spec.check_defaults.interval = 60
