#sensu_spec_definition 'has check_cmd' do
#  command 'check_cmd -c "echo hi" -o "hi"'
#end

define /has command (?<name>.*)/ do
  command 'check_command :::name:::'
  code <<-EOF
    #!/bin/bash
    which $1 >/dev/null 2>&1 || { echo "CRITICAL - cannot find command $1" && exit 2; }
    echo "OK - found command $1"; exit 0
  EOF
end
