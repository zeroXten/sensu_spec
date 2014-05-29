%w[ conf_dir plugin_dir spec_dir ].each do |dir|
  directory node['sensu_spec'][dir] do
    owner "root"
    group "root"
    mode 0755
    recursive true
  end
end

define /must have (?<count>\d+) (?<name>\w+) animals?/ do
  command 'check_animal ":::name::: count is :::count:::"'
  code <<-EOH
  #!/bin/bash
  echo "OK - $1"
  exit 1
  EOH
end

define /must have (?<stuff>.+) cool stuff/ do
  command 'check_cool :::stuff:::'
end

define /must have (?<count>\d+) (?<name>\w+) process with args (?<arg>.*)/ do
  command 'check_procs -C :::name::: -c :::count::: -a :::arg:::'
end


# Pretend to be client A
describe 'animals' do
  describe 'badgers' do
    it 'must have 1 badger animal'
  end
end
node.default.sensu_spec.checks.check_animals_badgers.interval = 30

describe 'logstash agent' do
  describe 'process' do
    it 'must have 1 java process with args logstash/agent'
  end
end

describe 'logstash server' do
  describe 'process' do
    it 'must have 1 java process with args logstash/server'
  end
end

# Pretend to be client B
describe 'animals' do
  describe 'bagers' do
    it 'must have 5 badger animals'
  end
end

describe 'elasticsearch' do
  describe 'process' do
    it 'must have 1 java process with args elasticsearch'
  end
end

# Pretend to be a sensu server
include_recipe 'sensu_spec::server'
