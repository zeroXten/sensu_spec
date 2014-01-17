#!/usr/bin/env python

from glob import glob
from pprint import pprint
import json
import subprocess
import sys

ok = 0
warning = 0
critical = 0
unknown = 0

for file in glob("/etc/sensu/conf.d/*.json"):
  fh = open(file)
  json_data = json.load(fh)
  fh.close()

  for check in json_data['checks']:
    command = json_data['checks'][check]['command']

    sys.stdout.write(check+" ")

    process = subprocess.Popen(command, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    exit_code = process.wait()
    (stdout,stderr) = process.communicate()
    
    if (exit_code == 0):
      print "OK"
      ok += 1
    elif (exit_code == 1):
      print "WARNING"
      print stdout
      warning += 1
    elif (exit_code == 2):
      print "CRITICAL"
      print stdout
      critical += 1
    else:
      print "UNKNOWN"
      print stdout
      unknown += 1


total = ok + warning + critical + unknown

if (total == 0):
  print "No tests run"
  sys.exit(0)
elif (ok == 0):
  print "All tests failed"
  sys.exit(1)
elif (total != ok):
  print "Some tests failed"
  sys.exit(1)
else:
  print "All tests passed"
  sys.exit(0)
