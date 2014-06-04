include_recipe 'sensu_spec'
include_recipe 'sensu_spec::definitions'

describe 'command' do
  describe 'bash' do
    it 'must has command bash'
  end
end
