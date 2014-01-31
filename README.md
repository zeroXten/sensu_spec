sensu\_spec cookbook
===================

This cookbook is an attempt at blurring the boundary between TDD and monitoring. It provides an LWRP that creates Sensu client configuration files that are processed by a minitest-chef-handler test for testing, or can be used by sensu in the traditional way.

At the moment it only creates the config files locally, but in future it will use attributes to make the configuration data available to a chef-managed sensu server.

At the moment, this cookbook is completely independant from any sensu cookbooks. This may change in future.

Requirements
------------

Uses apt cookbook for debian-like systems and yum-epel for rhel family systems, primarily to install nagios plugins.

Usage
-----

### Basic example

The simplest usage is just to provide a command

    sensu_spec 'check http availability' do
       command 'check_http -H localhost'
    end

Something more specific

    sensu_spec 'check ruby version' do
      command 'check_cmd -c "ruby --version" -o "1.9.3"'
      interval 120
      handlers [ 'ruby' ]
    end

You can then run `sensu_spec` from the command line

    $ sensu_spec
    test_critical CRITICAL
    TESTING CRIT

    test_unknown UNKNOWN
    TESTING UNKNOWN

    test_warn WARNING
    TESTING WARN

    test_ok OK
    Some tests failed

This command is automatically run by minitest. See `files/default/test/default_test.rb`.

Attributes
----------

See attributes/default.rb for default values.

* `node['sensu_spec']['conf_dir']` - Location of sensu check config
* `node['sensu_spec']['nagios']['plugins_path']` - Location of nagios plugins
* `node['sensu_spec']['nagios']['packages']` - Name of nagios plugins package
* `node['sensu_spec']['default_command_path']` - Path to use for relative commands
* `node['sensu_spec']['retry_count']` - Number of times to retry a test
* `node['sensu_spec']['retry_sleep'] - Number of seconds to sleep between test retries

Recipes
-------

* `default` - Includes the `client` recipe
* `client` - Installs require directory and nagios packages etc.

Author
--------

Author:: fraser.scott@gmail.com
