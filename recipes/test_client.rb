include_recipe 'sensu_spec'
include_recipe 'sensu_spec::definitions'

dsecribe 'command' do
  describe 'bash' do
    it 'has command bash'
  end
end
