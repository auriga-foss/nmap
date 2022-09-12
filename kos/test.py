#!/usr/bin/env python

import re
import sys
from subprocess import Popen, PIPE, DEVNULL

cmd = ['make', 'unittest-run']
print("Starting command:\n    ", " ".join(cmd))
pipe = Popen(cmd, stdout=PIPE, stderr=PIPE)

passed_flag = False
(suite_count, passed_sum, total_sum) = (0, 0, 0)
traceback_suites = []
notloaded_suites = []
current_suite = "(unknown)"

for line in pipe.stdout:
    sys.stdout.buffer.write(line)
    sys.stdout.flush()
    match = re.search(b"\[unittest\] Testing (.*)", line)
    if match:
        current_suite = match.group(1).decode('utf-8').strip()
    match = re.search(b"(\d*) of (\d*) tests passed", line)
    if match:
        suite_count += 1
        passed_count = int(match.group(1))
        total_count = int(match.group(2))
        passed_sum += passed_count
        total_sum += total_count
    if b"stack traceback:" in line:
        traceback_suites.append(current_suite)
    if b"[unittest] Failed to load" in line:
        notloaded_suites.append(current_suite)
    if b"unittest: All tests passed" in line:
        passed_flag = True
    if b"NSE: Script Post-scanning." in line:
        pipe.terminate()
        break

print('-'*78)
print(' '*30 + 'test.py summary')
print('-'*78)
print("Passed:\t\t\t", passed_sum,
      " tests (in ", suite_count, " executed suites)", sep='')
print("Total:\t\t\t", total_sum, sep='')
# traceback is not currently counted/detected as failed in nmap:
if traceback_suites:
    print("Traceback suites:\t", len(traceback_suites),
          "\n\t\t\t(", ", ".join(traceback_suites), ")", sep='')

if notloaded_suites:
    print("Not-loaded suites:\t", len(notloaded_suites),
          "\n\t\t\t(", ", ".join(notloaded_suites), ")", sep='')

ok = passed_flag and len(traceback_suites) == 0 and len(notloaded_suites) == 0
print("SUCCESS" if ok else "FAIL")
exit(0 if ok else 1)
