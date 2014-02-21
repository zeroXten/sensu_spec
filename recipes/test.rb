include_recipe 'sensu_spec'

sensu_spec "check procs" do
  command "check_procs"
end

sensu_spec 'check_cmd' do
  command 'check_cmd -c "echo hi" -o "hi"'
end
