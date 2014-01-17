Feature: Test all the devops

  In order to be super effective
  As an infrastructure engineer
  I want to use all the awesome tools

Background:

  Given I have provisioned the following infrastructure:
  | Server Name         | Operating System    | Version   | Box | Run List         |
  | sensu_spec-centos-6_5   | centos              | 6.5       | centos-6_5-64-chef_11 | sensu_spec::default |
  And I have run Chef

Scenario: System has bash
  When I look for "bash"
  Then I should see "/bin/bash"
