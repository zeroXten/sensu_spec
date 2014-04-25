require 'json'

if Chef::Config[:solo] 
  Chef::Log.debug "In solo mode so only using current node"
  nodes = [node]
else
  nodes = search(:node, node['sensu_spec']['client_search'])
end

nodes.each do |client|
  Chef::Log.debug "HIHIHI"
  Chef::Log.debug client['sensu_spec']['checks'] 
  client['sensu_spec']['checks'].each_pair do |check,check_data|
    file "#{node['sensu_spec']['conf_dir']}/#{node.name.gsub(/[^\w]+/,'_')}-#{check.gsub(/[^\w]+/,'_')}.json" do
      owner "root"
      group "root"
      mode 0644
      content JSON.pretty_generate(check_data)
    end
  end
end
