sensu\_spec cookbook
===================

sensu\_spec attempts to blur the line between TDD and monitoring.

One way to achieve this is to use something like serverspec to write test, then to send the results to Sensu. This is great, but seems to be a limited approach. I think you'd have to jump through a number of hoops to be able to reuse existing monitoring plugins, and getting metrics out would probably be a bit painful.

This cookbook is an experiment that starts with standard monitoring tools and attempts to turn them into specs.

A quick overview
==================

If you want something basic, you can use the definitions that come with this cookbook. But first, you need to use the cookbook.

Edit metadata.rb in your cookbook and add

    depends 'sensu_spec'

Then install using berkshelf

    $ berks update


Now, lets say your cookbook is going to install and configure a logstash server. You'll probably want to start off by writing a recipe called spec.rb:

    include_recipe 'sensu_spec'

    describe 'logstash' do
      describe 'java' do
        it 'must have command java'
      end

      describe 'java version' do
        it 'must match "1\.7.*(\n|.)*HotSpot" when I run "java -version"'
      end
    end

    describe 'logstash agent' do
      describe 'directory' do
        it 'must have directory /opt/logstash/agent'
      end

      describe 'jar' do
        it "must have readable file /opt/logstash/agent/lib/logstash-#{node.logstash.agent.version}.jar"
      end

      describe 'process' do
        it 'must have 1 java process with args logstash/agent'
      end
    end

    describe 'logstash server' do
      describe 'directory' do
        it 'must have directory /opt/logstash/server'
      end

      describe 'jar' do
        it "must have readable file /opt/logstash/server/lib/logstash-#{node.logstash.server.version}.jar"
      end

      describe 'process' do
        it 'must have 1 java process with args logstash/server'
      end
    end

That looks pretty straight forward. We're describing our requirements using something like natural language.

The magic happens because sensu\_spec::default is including the definitions that come with this cookbook. For example:

    define /must have (?<count>\d+) (?<name>.+?) process(?:es)? with args (?<args>.*)/ do
      command 'check-procs-args :::name::: :::count::: ":::args:::"'
      code <<-EOF
        #!/bin/bash
        num_procs=$(ps --no-headers -f -C $1 | grep $3 | wc -l)
        [[ $num_procs != $2 ]] && { echo "CRITICAL - $num_procs $1 process(es) with args $3 found. Expected $2"; exit 2; }
        echo "OK - $2 $1 process(es) with args $3 found"; exit 0
      EOF
    end

The command should look familiar, it will be mapped to a Sensu check command. The code attribute is optional, but if provided it will create the command specified with that code. In this case we're using bash to write a little check to monitor processes.

When a specification matches a definition, some magic happens to combine the two to turn them into standalone checks that can be run during tests, and Sensu client and server configuration

Writing specs
=============

Writing definitions
===================

Plumbing
========

Testing
=======

Sensu client
============


Sensu server
============

Conventions
===========

Contributing
============

Author
======
