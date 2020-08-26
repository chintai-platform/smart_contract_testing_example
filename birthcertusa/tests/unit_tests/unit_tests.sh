#!/bin/bash

function run_all_unit_tests(){
  echo "Running all unit tests"
  unit_test_validate
  unit_test_insert
  unit_test_set_retirement_date
  unit_test_calculate_retirement_date
}

function unit_tests_setup()
{
  result=$(setup_contract)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set up birthcertusa contract: $result"
    return 1
  fi
  echo $result
}

function unit_test_validate()
{
  unit_test_validate_account_doesnt_exist
  unit_test_validate_invalid_name
  unit_test_validate_future_birth
  unit_test_validate_success
}

function unit_test_validate_account_doesnt_exist()
{
  local start_time=$(date +%s.%3N)
  birthcertusa=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcertusa contract: $result"
    return 1
  fi

  account=$(generate_random_name)

  result=$( (cleos push action -f $birthcertusa testvalidate "{\"account\":\"$account\", \"full_name\":\"John Doe\", \"date_of_birth\":\"1990-01-01T00:00:00\"}" -p $birthcertusa) 2>&1)
  if [[ $result != *"The account $account does not exist"* ]]
  then
    test_fail "${FUNCNAME[0]}: Unexpected error message: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}

function unit_test_validate_invalid_name
{
  local start_time=$(date +%s.%3N)
  birthcertusa=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcertusa contract: $result"
    return 1
  fi

  account=$(create_random_account)

  result=$( (cleos push action -f $birthcertusa testvalidate "{\"account\":\"$account\", \"full_name\":\"\", \"date_of_birth\":\"1990-01-01T00:00:00\"}" -p $birthcertusa) 2>&1)
  if [[ $result != *"The name must not be an empty string"* ]]
  then
    test_fail "${FUNCNAME[0]}: Unexpected error message: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}

function unit_test_validate_future_birth
{
  local start_time=$(date +%s.%3N)
  birthcertusa=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcertusa contract: $result"
    return 1
  fi

  account=$(create_random_account)

  result=$( (cleos push action -f $birthcertusa testvalidate "{\"account\":\"$account\", \"full_name\":\"John Doe\", \"date_of_birth\":\"3000-01-01T00:00:00\"}" -p $birthcertusa) 2>&1)
  if [[ $result != *"The birth must have happened in the past"* ]]
  then
    test_fail "${FUNCNAME[0]}: Unexpected error message: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}

function unit_test_validate_success
{
  local start_time=$(date +%s.%3N)
  birthcertusa=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcertusa contract: $result"
    return 1
  fi

  account=$(create_random_account)

  result=$( (cleos push action -f $birthcertusa testvalidate "{\"account\":\"$account\", \"full_name\":\"John Doe\", \"date_of_birth\":\"1990-01-01T00:00:00\"}" -p $birthcertusa) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Validate function failed when it should have succeeded: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}

function unit_test_insert()
{
  unit_test_insert_certificate_id_exists
  unit_test_insert_success
}

function unit_test_insert_certificate_id_exists
{
  local start_time=$(date +%s.%3N)
  birthcertusa=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcertusa contract: $result"
    return 1
  fi
  account=$(generate_random_name)
  certificate_id=1

  result=$( (cleos push action -f $birthcertusa mockcert "{\"certificate_id\":$certificate_id, \"account\":\"$account\", \"full_name\":\"John Doe\", \"date_of_birth\":\"1990-01-01T00:00:00\"}" -p $birthcertusa) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create a mock of the certificate: $result"
    return 1
  fi

  result=$( (cleos push action -f $birthcertusa testinsert "{\"certificate_id\":$certificate_id, \"account\":\"$account\", \"full_name\":\"John Doe\", \"date_of_birth\":\"1990-01-01T00:00:00\"}" -p $birthcertusa) 2>&1)
  if [[ $result != *"A certificate with ID $certificate_id already exists"* ]]
  then
    test_fail "${FUNCNAME[0]}: Unexpected error message: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}

function unit_test_insert_success
{
  local start_time=$(date +%s.%3N)
  birthcertusa=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcertusa contract: $result"
    return 1
  fi
  certificate_id=1
  account=$(generate_random_name)
  full_name="John Doe"
  date_of_birth="1990-01-01T00:00:00.000"

  result=$( (cleos push action -f $birthcertusa testinsert "{\"certificate_id\":$certificate_id, \"account\":\"$account\", \"full_name\":\"$full_name\", \"date_of_birth\":\"$date_of_birth\"}" -p $birthcertusa) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Insert function failed when it should have succeeded: $result"
    return 1
  fi

  certificate=$( (cleos get table $birthcertusa $birthcertusa certificates | jq -r ".rows[0]") 2>&1)
  observed_certificate_id=$(echo $certificate | jq -r .certificate_id)
  observed_account=$(echo $certificate | jq -r .account)
  observed_full_name=$(echo $certificate | jq -r .full_name)
  observed_date_of_birth=$(echo $certificate | jq -r .date_of_birth)

  if [[ $observed_certificate_id != $certificate_id ]]
  then
    test_fail "${FUNCNAME[0]}: Incorrect certificate_id in certificates table, expected \"$certificate_id\" but observed \"$observed_certificate_id\""
    return 1
  fi
  if [[ $observed_account != $account ]]
  then
    test_fail "${FUNCNAME[0]}: Incorrect account in certificates table, expected \"$account\" but observed \"$observed_account\""
    return 1
  fi
  if [[ $observed_full_name != $full_name ]]
  then
    test_fail "${FUNCNAME[0]}: Incorrect full_name in certificates table, expected \"$full_name\" but observed \"$observed_full_name\""
    return 1
  fi
  if [[ $observed_date_of_birth != $date_of_birth ]]
  then
    test_fail "${FUNCNAME[0]}: Incorrect date_of_birth in certificates table, expected \"$date_of_birth\" but observed \"$observed_date_of_birth\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}

function unit_test_set_retirement_date()
{
  unit_test_set_retirement_date_no_retirement_contract
  unit_test_set_retirement_date_success
}

function unit_test_set_retirement_date_no_retirement_contract()
{
  local start_time=$(date +%s.%3N)
  birthcertusa=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcertusa contract: $result"
    return 1
  fi
  account=$(generate_random_name)
  retirement_date="1990-01-01T00:00:00.000"

  result=$( (cleos push action -f $birthcertusa testretdate "{\"account\":\"$account\", \"retirement_date\":\"$retirement_date\"}" -p $birthcertusa) 2>&1)
  if [[ $result != *"The retirement contract has not been set"* ]]
  then
    test_fail "${FUNCNAME[0]}: Unexpected error message: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}

function unit_test_set_retirement_date_success()
{
  local start_time=$(date +%s.%3N)
  birthcertusa=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcertusa contract: $result"
    return 1
  fi
  account=$(generate_random_name)
  retirement_date="1990-01-01T00:00:00.000"
  retirement_contract=$(setup_mock_retirementus_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create a mock of the retirement contract"
    return 1
  fi

  result=$( (cleos push action -f $birthcertusa mockretire "{\"account\":\"$retirement_contract\"}" -p $birthcertusa) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create a mock of the certificate: $result"
    return 1
  fi

  result=$( (cleos push action -f $birthcertusa testretdate "{\"account\":\"$account\", \"retirement_date\":\"$retirement_date\"}" -p $birthcertusa) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Function failed unexpectedly: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}

function unit_test_calculate_retirement_date()
{
  local start_time=$(date +%s.%3N)
  birthcertusa=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcertusa contract: $result"
    return 1
  fi
  date_of_birth="1990-01-01T00:00:00.000"
  retirement_date=$(date -d "1990-01-01 + 2049840000 seconds" +%s -u) # Number of seconds in 65 years (65*365*24*60*60)

  result=$( (cleos push action -f -j $birthcertusa testcalcret "{\"date_of_birth\":\"$date_of_birth\"}" -p $birthcertusa) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Function failed unexpectedly: $result"
    return 1
  fi

  result=$(echo $result | jq -r ".processed.action_traces[] | select(.act.name == \"testcalcret\") | .console") # This is how you access the console for a specific action
  if [[ $result != $retirement_date ]]
  then
    test_fail "${FUNCNAME[0]}: Expected retirement age to be \"$retirement_date\", but observed \"$result\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}
