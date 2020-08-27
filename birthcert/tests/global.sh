#!/bin/bash

trap 'clean_exit' SIGINT

private_key=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
public_key=EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV

echo 0 > tests_passed
echo 0 > tests_failed
echo 0 > tests_total

test_lock=./test_status.lock

clean_exit(){
  time_taken=$1
  close_nodeos
  local exit_code=$(cat tests_failed)
  sed -i '2i<testsuites id="all_tests" name="Full Test Suite" tests="'$(cat tests_total)'" failures="'$(cat tests_failed)'" time="'$time_taken'">' $test_report
  sed -i '3i<testsuite id="test_suite" name="Test Suite" tests="'$(cat tests_total)'" failures="'$(cat tests_failed)'" time="'$time_taken'">' $test_report
  echo '</testsuite> </testsuites>' >> $test_report
  rm -f tests_passed
  rm -f tests_failed
  rm -f tests_total
  rm -rf $test_lock
  exit $exit_code
}

test_pass(){
  while true
  do
    result=$( (mkdir $test_lock) 2>&1)
    if [[ $? -eq 0 ]]
    then
      break
    fi
  done
  
  local test_name=$1
  local time_taken=$2
  
  echo -e "\e[32mTest Passed: $@\e[0m"
  local tests_passed=$(cat tests_passed)
  local tests_total=$(cat tests_total)
  tests_passed=$(echo "$tests_passed+1" | bc)
  tests_total=$(echo "$tests_total+1 " | bc)
  echo $tests_passed > tests_passed
  echo $tests_total > tests_total
  
  echo '<testcase id="'$test_name'" name="'$test_name'" time="'$time_taken'"> </testcase>' >> $test_report

  rmdir $test_lock
}

test_fail(){
  while true
  do
    result=$( (mkdir $test_lock) 2>&1)
    if [[ $? -eq 0 ]]
    then
      break
    fi
  done
  
  local test_name=$1
  local time_taken=$2

  echo -e "\e[31mTest Failed: \e[0m$@"
  local tests_failed=$(cat tests_failed)
  local tests_total=$(cat tests_total)
  tests_failed=$(echo "$tests_failed+1" | bc)
  tests_total=$(echo "$tests_total+1" | bc)
  echo $tests_failed > tests_failed
  echo $tests_total > tests_total

  # test_name=$(echo $test_name | sed 's/"/\\"/g')
  echo "<testcase id='$test_name' name='$test_name' time='$time_taken'>" >> $test_report
  echo "<failure message='$test_name' type='ERROR'> </failure> </testcase>" >> $test_report

  rmdir $test_lock
}

setup_nodeos(){
  result=$( (killall nodeos) 2>&1)
  nodeos --delete-all-blocks --config-dir $BIRTH_CERTIFICATE_CONTRACT/tests >& nodeos.log &
  nodeos_pid=$!
  if [[ $? -ne 0 ]]
  then
    echo "Nodeos failed to start"
    cat nodeos.log
    exit 1
  fi
  sleep 1 # Necessary to give enough time for nodeos to get started before running any commands on nodeos
}

setup_wallet(){
  rm -f ~/eosio-wallet/localtestnet.wallet
  result=$( (cleos wallet create -n localtestnet -f localtestnet.key) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo $result
    exit 1
  fi
  result=$( (cleos wallet import -n localtestnet --private-key $private_key) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to import private key: $result"
    exit 1
  fi
}

# Timeout function
# Used to attempt a function multiple times
# Arguments are: 
# $1 command to execute
# $2 timeout limit
timeout(){
  COUNTER=0
  while [ $COUNTER -lt $2 ]; do
    result=$( ( $1 ) 2>& 1 )
    if [[ $? -eq 0 ]]
    then break
    fi
    let COUNTER=COUNTER+1 
    if [[ $COUNTER -eq $2 ]]
    then
      echo "Failure when trying to execute:"
      echo $1
      echo $result
      return 1
    fi
  done
}

setup_system_contracts(){
  accounts=(bpay msig names ram ramfee saving stake token vpay rex)

  for i in  "${accounts[@]}"
  do
    result=$( (cleos create account eosio eosio.$i $public_key -p eosio) 2>&1)
    if [[ $? -ne 0 ]]
    then
      echo "Failed to create account eosio.$i"
      echo $result
    fi
  done

  timeout "cleos set contract eosio.token $EOSIO_CONTRACTS_DIRECTORY/build/contracts//eosio.token" 20
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set contract eosio.token"
  fi
  timeout "cleos set contract eosio.msig $EOSIO_CONTRACTS_DIRECTORY/build/contracts//eosio.msig" 20
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set contract eosio.msig"
  fi
  result=$( (cleos push action -f eosio.token create '[ "eosio", "10000000000.0000 EOS" ]' -p eosio.token) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to create EOS tokens with eosio.token"
    echo $result
  fi
  result=$( (cleos push action -f eosio.token issue '[ "eosio", "1000000000.0000 EOS", "memo" ]' -p eosio) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to issue EOS tokens to eosio"
    echo $result
  fi
  result=$( (cleos push action -f eosio.token create '[ "eosio", "10000000000.0000 WAX" ]' -p eosio.token) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to create WAX tokens with eosio.token"
    echo $result
  fi
  result=$( (cleos push action -f eosio.token issue '[ "eosio", "1000000000.0000 WAX", "memo" ]' -p eosio) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to issue WAX tokens to eosio"
    echo $result
  fi

  #result=$( (curl -s -X POST http://127.0.0.1:8888/v1/producer/get_supported_protocol_features -d '{}') 2>&1)

  result=$( (curl -s -X POST http://127.0.0.1:8888/v1/producer/schedule_protocol_feature_activations -d '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}') 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to preactivate feature"
    echo $result
  fi

  sleep 0.5

  timeout "cleos set contract eosio $EOSIO_OLD_CONTRACTS_DIRECTORY/build/contracts//eosio.system" 20
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set contract for eosio"
  fi

  result=$( (cleos push action eosio activate '["f0af56d2c5a48d60a4a5b5c903edfb7db3a736a94ed589d0b797df33ff9d3e1d"]' -p eosio) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["2652f5f96006294109b3dd0bbde63693f55324af452b799ee137a81a905eed25"]' -p eosio) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["8ba52fe7a3956c5cd3a656a3174b931d3bb2abb45578befc59f283ecd816a405"]' -p eosio) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["ad9e3d8f650687709fd68f4b90b41f7d825a365b02c23a636cef88ac2ac00c43"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["68dcaa34c0517d19666e6b33add67351d8c5f69e999ca1e37931bc410a297428"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["e0fb64b1085cc5538970158d05a009c24e276fb94e1a0bf6a528b48fbc4ff526"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["ef43112c6543b88db2283a2e077278c315ae2c84719a8b25f25cc88565fbea99"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["4a90c00d55454dc5b059055ca213579c6ea856967712a56017487886a4d4cc0f"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["1a99a59d87e06e09ec5b028a9cbb7749b4a5ad8819004365d02dc4379a8b7241"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["4e7bf348da00a945489b2a681749eb56f5de00b900014e137ddae39f48f69d67"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["4fca8bd82bbd181e714e283f83e1b45d95ca5af40fb89ad3977b653c448f78c2"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["299dcb6af692324b899b39f16d5a530a33062804e41f09dc97e9f156b4476707"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi

  sleep 0.5

  timeout "cleos set contract eosio $EOSIO_CONTRACTS_DIRECTORY/build/contracts//eosio.system" 20
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set contract for eosio"
  fi

  result=$( (cleos push action eosio init '{"version":"0","core":"4,EOS"}' -p eosio) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo $result
  fi
}

function generate_random_name()
{
  echo $(head /dev/urandom | tr -dc a-z | head -c 12 ; echo '')
}

function create_random_account()
{
  account=$(generate_random_name)
  result=$( (cleos system newaccount eosio $account $public_key --stake-net "100000 EOS" --stake-cpu "100000 EOS" --buy-ram-kbytes 10000) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to create account $account"
    echo $result
  fi
  echo $account
}

function setup_contract()
{
  local contract_name=$(generate_random_name)
  result=$( (cleos system newaccount eosio $contract_name $public_key --stake-net "100000 EOS" --stake-cpu "100000 EOS" --buy-ram-kbytes 10000) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to create account $contract_name"
    echo $result
    return 1
  fi
  timeout "cleos set contract $contract_name $BIRTH_CERTIFICATE_CONTRACT/build/birthcert birthcert_local.wasm birthcert_local.abi" 20
  result=$( (cleos set account permission $contract_name active --add-code) 2>&1 )
  if [[ $? -ne 0 ]]
  then
    echo "Failed to add eosio.code permission"
    echo $result
    return 1
  fi
  echo $contract_name
}

function setup_retirement_contract()
{
  local contract_name=$(generate_random_name)
  result=$( (cleos system newaccount eosio $contract_name $public_key --stake-net "100000 EOS" --stake-cpu "100000 EOS" --buy-ram-kbytes 10000) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to create account $contract_name"
    echo $result
    return 1
  fi
  timeout "cleos set contract $contract_name $RETIREMENT_CONTRACT/build/retirement retirement.wasm retirement.abi" 20
  result=$( (cleos set account permission $contract_name active --add-code) 2>&1 )
  if [[ $? -ne 0 ]]
  then
    echo "Failed to add eosio.code permission"
    echo $result
    return 1
  fi
  echo $contract_name
}

function setup_mock_retirement_contract()
{
  local contract_name=$(generate_random_name)
  result=$( (cleos system newaccount eosio $contract_name $public_key --stake-net "100000 EOS" --stake-cpu "100000 EOS" --buy-ram-kbytes 10000) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to create account $contract_name"
    echo $result
    return 1
  fi
  timeout "cleos set contract $contract_name $BIRTH_CERTIFICATE_CONTRACT/build/birthcert mockretire.wasm mockretire.abi" 20
  result=$( (cleos set account permission $contract_name active --add-code) 2>&1 )
  if [[ $? -ne 0 ]]
  then
    echo "Failed to add eosio.code permission"
    echo $result
    return 1
  fi
  echo $contract_name
}

setup_system(){
  setup_nodeos
  setup_wallet
  setup_system_contracts
}

close_nodeos(){
  tests_passed=$(cat tests_passed)
  tests_failed=$(cat tests_failed)
  tests_total=$(cat tests_total)
  killall nodeos
  if [[ $tests_passed -gt 0 ]]
  then echo -e "\e[32m$tests_passed/$tests_total Passed\e[0m"
  fi
  if [[ $tests_failed -gt 0 ]]
  then echo -e "\e[31m$tests_failed/$tests_total Failed\e[0m"
  fi
}

