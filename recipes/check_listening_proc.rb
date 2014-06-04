# Need root to see pid for listening process. Using cron do dump data to file that can be checked
collection_command = '/bin/netstat -npl > /var/tmp/netstat-output 2>&1 && /bin/ps ax --no-headers -o pid,comm,args > /var/tmp/ps-output 2>&1'

# Run the first time if required
bash 'collect_process_data' do
  cwd '/var/tmp'
  command collection_command
  not_if "test -r /var/tmp/netstat-output && test -r /var/tmp/ps-output"
end

cron 'collect_process_data' do
  home '/var/tmp'
  command collection_command
end

define /must have process (?<process>.+?) with args (?<args>.+?) listening on (?<proto>tcp|udp) (?<address>.*)/ do
  command 'check_listening_proc :::process::: :::args::: :::proto::: :::address:::'
  code <<-'EOF'
    #!/bin/bash
    process=$1
    args=$2
    proto=$3
    address=$4

    if [[ ! -r /var/tmp/netstat-output ]]; then
      echo "UNKNOWN - netstat output file does not exist"; exit 3
    fi

    if [[ ! -r /var/tmp/ps-output ]]; then
      echo "UNKNOWN - ps output file does not exist"; exit 3
    fi

    pid=$(awk "{ if (\$1 == \"$proto\" && \$4 ~ /$address/) { print \$NF } }" /var/tmp/netstat-output | cut -d'/' -f1)
    if [[ -z "$pid" ]]; then
      echo "CRITICAL - Could not find a process listening on ${proto} ${address}"; exit 2
    fi

    output=$(awk "{ if (\$1 == \"$pid\" && \$2 == \"$process\") { print \$0 } }" /var/tmp/ps-output | grep "$args")
    if [[ "$?" -eq "0" ]]; then
      echo "OK - Found ${process} process (${pid}) with args '${args}' listening on ${proto} ${address}"; exit 0
    else
      echo "CRITICAL - Found process ${pid} listening on ${proto} ${address} but does not match ${process} with args ${args}"; exit 2
    fi
  EOF
end

