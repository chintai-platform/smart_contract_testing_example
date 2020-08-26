#!/bin/bash

source $BIRTH_CERTIFICATE_CONTRACT/tests/global.sh
source $BIRTH_CERTIFICATE_CONTRACT/tests/unit_tests/unit_tests.sh
source $BIRTH_CERTIFICATE_CONTRACT/tests/component_tests/component_tests.sh
source $BIRTH_CERTIFICATE_CONTRACT/tests/integration_tests/integration_tests.sh

run_test_suite(){
  local starttime=$(date +%s)
  local timestamp=$(date -u +%Y-%m-%dT%H:%M:%S)
  test_report=$BIRTH_CERTIFICATE_CONTRACT/tests/reports/test_report_$start_time.xml
  echo '<?xml version="1.0" encoding="UTF-8" ?>' > $test_report
  setup_system
  sleep 1
  run_all_unit_tests
  run_all_component_tests
  run_all_integration_tests
  for job in `jobs -p`
  do
    if [[ $job -ne $nodeos_pid ]]
    then
      wait $job
    fi
  done
  local endtime=$(date +%s)
  local time_taken=$(( endtime - starttime ))
  echo "Tests took $time_taken second(s) to complete"

  clean_exit $time_taken
}

run_test_suite
