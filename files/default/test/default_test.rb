require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

# Documentation can be found here:
#  https://github.com/seattlerb/minitest
#  http://docs.seattlerb.org/minitest/

# Basic tests
class TestSensuSpec < MiniTest::Chef::TestCase
  def test_sensu_spec_run
    cmd = shell_out "sensu_spec_run.py"
    assert_equal(cmd.exitstatus, 0)
  end
end

