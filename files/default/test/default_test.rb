require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
require 'shellwords'

# Documentation can be found here:
#  https://github.com/seattlerb/minitest
#  http://docs.seattlerb.org/minitest/

# Basic tests
class TestSensuSpec < MiniTest::Chef::TestCase
  def test_sensu_spec_run
    cmd = shell_out Shellwords.join([ "/usr/bin/sensu_spec", '-p', node['sensu_spec']['spec_dir'].to_s, '-r', node['sensu_spec']['retry_count'].to_s, '-s', node['sensu_spec']['retry_sleep'].to_s ])
    assert_equal(cmd.exitstatus, 0)
  end
end

