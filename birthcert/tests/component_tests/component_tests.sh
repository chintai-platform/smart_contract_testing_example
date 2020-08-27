#!/bin/bash

function run_all_component_tests(){
  echo "Running all component tests"
  component_test_add_birth_certificate
  component_test_set_retirement_contract
}

function component_test_add_birth_certificate()
{
  component_test_add_birth_certificate_wrong_authority
  component_test_add_birth_certificate_success
}

function component_test_add_birth_certificate_wrong_authority
{
  local start_time=$(date +%s.%3N)
  birthcert=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcert contract: $result"
    return 1
  fi
  account=$(create_random_account)

  result=$( (cleos push action -f $birthcert add "{\"certificate_id\":1 \"account\":\"$account\", \"full_name\":\"John Doe\", \"date_of_birth\":\"1990-01-01T00:00:00\"}" -p $account) 2>&1)
  if [[ $result != *"Missing required authority"* ]]
  then
    test_fail "${FUNCNAME[0]}: Unexpected error message: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}

function component_test_add_birth_certificate_success
{
  local start_time=$(date +%s.%3N)
  birthcert=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcert contract: $result"
    return 1
  fi
  retirement_contract=$(setup_mock_retirement_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create a mock of the retirement contract"
    return 1
  fi

  certificate_id=1
  account=$(create_random_account)
  full_name="John Doe"
  date_of_birth="1990-01-01T00:00:00.000"

  result=$( (cleos push action -f $birthcert mockretire "{\"account\":\"$retirement_contract\"}" -p $birthcert) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create a mock of the certificate: $result"
    return 1
  fi

  result=$( (cleos push action -f $birthcert add "{\"certificate_id\":$certificate_id, \"account\":\"$account\", \"full_name\":\"$full_name\", \"date_of_birth\":\"$date_of_birth\"}" -p $birthcert) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: add action failed when it should have succeeded: $result"
    return 1
  fi

  certificate=$( (cleos get table $birthcert $birthcert certificates | jq -r ".rows[0]") 2>&1)
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

function component_test_set_retirement_contract()
{
  component_test_set_retirement_contract_wrong_authority
  component_test_set_retirement_contract_success
}

function component_test_set_retirement_contract_wrong_authority
{
  local start_time=$(date +%s.%3N)
  birthcert=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcert contract: $result"
    return 1
  fi
  account=$(create_random_account)

  result=$( (cleos push action -f $birthcert setretire "{\"account\":\"$account\"}" -p $account) 2>&1)
  if [[ $result != *"Missing required authority"* ]]
  then
    test_fail "${FUNCNAME[0]}: Unexpected error message: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}

function component_test_set_retirement_contract_success
{
  local start_time=$(date +%s.%3N)
  birthcert=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcert contract: $result"
    return 1
  fi
  account=$(create_random_account)

  result=$( (cleos push action -f $birthcert setretire "{\"account\":\"$account\"}" -p $birthcert) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: setretire action failed unexpectedly: $result"
    return 1
  fi

  retirement_account=$(cleos get table $birthcert $birthcert retirecontr | jq -r ".rows[0].account")
  if [[ $retirement_account != $account ]]
  then
    test_fail "${FUNCNAME[0]}: Expected retirement account to be \"$account\", but observed \"test_fail \"$retirement_account\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}
