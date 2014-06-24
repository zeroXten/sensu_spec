unless run_context.resource_collection.include?('ruby_block[sensu_service_trigger]')
  ruby_block 'sensu_service_trigger' do
    block do
      Chef::Log.debug "Dummy sensu_service_trigger"
    end
    action :nothing
  end
end
