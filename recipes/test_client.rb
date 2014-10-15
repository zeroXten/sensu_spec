include_recipe 'sensu_spec::client'

include_recipe 'sensu'
package "git"
git "/opt/sensu-community-plugins" do
  repository "https://github.com/sensu/sensu-community-plugins.git"
end

define /must run a community plugin/ do
  command '/opt/sensu-community-plugins/plugins/system/check-disk.rb'
end

describe 'sensu_spec test' do

  describe 'three levels deep' do
    describe 'the actual test' do
      it 'must pass with message "three levels"'
    end

    describe 'another test' do
      it 'must pass with message "three levels 2"'
    end
  end

  describe 'fail' do
    it 'must fail with message "it worked"'
  end

  describe 'command' do
    it 'must have command bash'
  end

  describe 'readable file' do
    it 'must have readable file /etc/passwd'
  end

  describe 'file contains' do
    it 'must have file /etc/passwd containing ^root'
  end

  describe 'directory' do
    it 'must have directory /etc'
  end

  describe 'process' do
    it 'must have 1 init process'
  end

  describe 'comparison process' do
    it 'must have at least 1 sshd process'
  end

  describe 'process with args' do
    it 'must have 1 sshd process with args sshd'
  end

  describe 'output match' do
    it 'must match "hello" when I run "echo hello"'
  end

  describe 'with' do
    it 'must match "hello" when I run "echo hello"'
    with :tags => ['sla-testing','hello']
  end

  describe 'with override' do
    it 'must pass with message "badger"'
    with interval: 120
  end

  describe 'community plugin' do
    it 'must run a community plugin'
  end
end
