sensu_spec_definition 'has check_cmd' do
  command 'check_cmd -c "echo hi" -o "hi"'
end

sensu_spec_definition 'has java' do
  command '/usr/bin/which java || (exit 2)'
end
