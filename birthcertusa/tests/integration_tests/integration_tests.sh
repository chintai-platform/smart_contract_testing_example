#!/bin/bash

function run_all_integration_tests(){
  echo "Running all integration tests"
  integration_test_add_birth_certificate
}

function integration_test_add_birth_certificate()
{
  integration_test_add_birth_certificate_success
}

function integration_test_add_birth_certificate_success
{
  local start_time=$(date +%s.%3N)
  birthcertusa=$(unit_tests_setup)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set up birthcertusa contract: $result"
    return 1
  fi
  retirement_contract=$(setup_retirementus_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create the retirement contract"
    return 1
  fi

  certificate_id=1
  account=$(create_random_account)
  full_name="John Doe"
  date_of_birth="1990-01-01T00:00:00.000"
  retirement_date="2054-12-16T00:00:00.000"

  result=$( (cleos push action -f $birthcertusa setretire "{\"account\":\"$retirement_contract\"}" -p $birthcertusa) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: setretire action failed unexpectedly: $result"
    return 1
  fi

  result=$( (cleos push action -f $retirement_contract authority "{\"account\":\"$birthcertusa\"}" -p $retirement_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: authority action failed unexpectedly: $result"
    return 1
  fi


  result=$( (cleos push action -f $birthcertusa add "{\"certificate_id\":$certificate_id, \"account\":\"$account\", \"full_name\":\"$full_name\", \"date_of_birth\":\"$date_of_birth\"}" -p $birthcertusa) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: add action failed when it should have succeeded: $result"
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

  reminder=$(cleos get table $retirement_contract $retirement_contract reminders | jq -r .rows[0])
  reminder_account=$(echo $reminder | jq -r .account)
  reminder_retirement_date=$(echo $reminder | jq -r .retirement_date)

  if [[ $reminder_account != $account ]]
  then
    test_fail "${FUNCNAME[0]}: Incorrect account in reminder table, expected \"$account\" but observe \"$reminder_account\""
    return 1
  fi
  if [[ $reminder_retirement_date != $retirement_date ]]
  then
    test_fail "${FUNCNAME[0]}: Incorrect retirement_date in reminder table, expected \"$retirement_date\" but observe \"$reminder_retirement_date\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}" $(echo "$(date +%s.%3N) - $starttime" | bc)
}
