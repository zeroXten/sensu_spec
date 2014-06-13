define /(?:must fail|fails) with message ['"]?(?<message>.*?)['"]?/ do
  command 'always-critical ":::message:::"'
  code <<-EOF
    #!/bin/bash
    echo "CRITICAL - $1"; exit 2
  EOF
end

define /must have command (?<name>.*)/ do
  command 'check-command :::name:::'
  code <<-EOF
    #!/bin/bash
    which $1 >/dev/null 2>&1 || { echo "CRITICAL - cannot find command $1" && exit 2; }
    echo "OK - found command $1"; exit 0
  EOF
end

define /must have (?<action>readable|writable|executable) file (?<file>.*)/ do
  command 'check-file :::file::: :::action:::'
  code <<-EOF
    #!/bin/bash
    result=1
    case $2 in
      "readable") test -r $1 && result=0;;
      "writable") test -w $1 && result=0;;
      "executable") test -x $1 && result=0;;
    esac
    [[ $result == 0 ]] || { echo "CRITICAL - file $1 does not exist or is not $2" && exit 2; }
    echo "OK - file $1 exists and is readable"; exit 0
  EOF
end

define /must have file (?<file>.+?) containing ['"]?(?<pattern>.+?)['"]?/ do
  command 'check-file-contains ":::file:::" ":::pattern:::"'
  code <<-EOF
    #!/bin/bash
    file="$1"
    pattern="$2"

    egrep -q "$pattern" "$file" || { echo "CRITICAL - Could not find pattern '$pattern' in $file"; exit 2; }
    echo "OK - Found pattern '$pattern' in $file"; exit 0 
  EOF
end

define /must have directory (?<dir>.*)/ do
  command 'check-dir :::dir:::'
  code <<-EOF
    #!/bin/bash
    test -d $1 || { echo "CRITICAL - Directory '$1' not found"; exit 2; }
    echo "OK - Directory '$1' found"; exit 0
  EOF
end

define /must have (?<count>\d+) (?<name>.+?) process(?:es)?/ do
  command 'check-procs :::name::: :::count:::'
  code <<-EOF
    #!/bin/bash
    num_procs=$(ps --no-headers -f -C $1 | wc -l)
    [[ $num_procs != $2 ]] && { echo "CRITICAL - $num_procs $1 process(es) found. Expected $2"; exit 2; }
    echo "OK - $2 $1 process(es) found"; exit 0
  EOF
end

define /must have (?<comparison>at least|at most|exactly) (?<count>\d+) (?<name>.+?) process(?:es)?/ do
  command 'check-procs-comp :::name::: :::count::: ":::comparison:::"'
  code <<-EOF
    #!/bin/bash

    name="$1"
    count="$2"
    comparison="${3:-exactly}"

    num_procs=$(ps --no-headers -f -C $1 | wc -l)

    ok='false'
    case "$comparison" in
      "at least") [[ $num_procs -ge $count ]];;
      "at most") [[ $num_procs -le $count ]];;
      *) [[ $num_procs -eq $count ]];;
    esac

    if [[ $? -eq 0 ]]; then
      echo "OK - $count $name process(es) found"; exit 0
    else
      echo "CRITICAL - $num_procs $name process(es) found. Expected $comparison $count"; exit 2
    fi
  EOF
end


define /must have (?<count>\d+) (?<name>.+?) process(?:es)? with args (?<args>.*)/ do
  command 'check-procs-args :::name::: :::count::: ":::args:::"'
  code <<-EOF
    #!/bin/bash
    num_procs=$(ps --no-headers -f -C $1 | grep $3 | wc -l)
    [[ $num_procs != $2 ]] && { echo "CRITICAL - $num_procs $1 process(es) with args $3 found. Expected $2"; exit 2; }
    echo "OK - $2 $1 process(es) with args $3 found"; exit 0
  EOF
end

define /must match "(?<match>.+?)" when I run "(?<command>.+)"/ do
  command 'check-output ":::command:::" ":::match:::"'
  code <<-EOF
    #!/bin/bash
    command="$1"
    match="$2"

    output=$($command 2>&1)
    
    echo "$output" | xargs | egrep -q "$2" || { echo "CRITICAL - Output for '$command' did not match '$match'. Got '$output' instead."; exit 2; }
    echo "OK - Command '$command' output matched '$match'"; exit 0
  EOF
end
