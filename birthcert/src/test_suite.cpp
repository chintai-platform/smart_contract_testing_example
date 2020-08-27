#if LOCAL

#include "test_suite.hpp"

void test_suite::test_validate(eosio::name const & account, std::string const & full_name, eosio::time_point const & date_of_birth)
{
  require_auth(get_self());
  validate(account, full_name, date_of_birth);
}

void test_suite::test_insert(uint64_t const certificate_id, eosio::name const & account, std::string const & full_name, eosio::time_point const & date_of_birth)
{
  require_auth(get_self());
  insert(certificate_id, account, full_name, date_of_birth);
}

void test_suite::test_set_retirement_date(eosio::name const & account, eosio::time_point const & retirement_date)
{
  require_auth(get_self());
  set_retirement_date(account, retirement_date);
}

void test_suite::test_calculate_retirement_date(eosio::time_point const & date_of_birth)
{
  require_auth(get_self());
  eosio::print(std::to_string(calculate_retirement_date(date_of_birth).sec_since_epoch()));
}

#endif
