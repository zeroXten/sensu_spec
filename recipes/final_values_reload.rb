# Need root to see pid for listening process. Using cron do dump data to file that can be checked
reload_command = 'sleep 10;n=$(/bin/netstat -npl 2>&1); echo "$n" > /var/tmp/netstat-output; p=$(/bin/ps ax --no-headers -o pid,comm,args 2>&1); echo "$p" > /var/tmp/ps-output'

# Run the first time if required
bash 'final_reload' do
  cwd '/var/tmp'
  code reload_command
  action :nothing
end

execute 'dummy' do
  command 'exit 0'
  notifies :run, 'bash[final_reload]', :delayed
end

