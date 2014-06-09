include_recipe 'sensu_spec::base'
include_recipe 'sensu_spec::definitions'

describe 'command' do
  describe 'bash' do
    it 'must have command bash'
  end
end

include_recipe 'sensu_spec::client'
