include_recipe 'sensu_spec::client'

describe 'sensu_spec test' do

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

  describe 'levels' do
    it 'must match "hello" when I run "echo hello"'
    it 'should match "badger" when I run "echo hello"'
  end

  describe 'with' do
    it 'must match "hello" when I run "echo hello"'
    with :tags => ['sla-testing','hello']
  end

end
