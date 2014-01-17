require 'chefspec'

describe 'sensu_spec::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge('sensu_spec::default') }
  it 'should include the client recipe by default' do
    chef_run.should include_recipe 'sensu_spec::client'
  end
end
