#if LOCAL

#include "mock_suite.hpp"
#include "certificate.hpp"
#include "retirement.hpp"

void mock_suite::mock_certificate_table(uint64_t const certificate_id, eosio::name const & account, std::string const & full_name, eosio::time_point const & date_of_birth)
{
  certificates_table certificates(get_self(), get_self().value);
  auto addentry = [&](auto & entry) { entry = certificate_t(certificate_id, account, full_name, date_of_birth);};
  if(certificates.find(certificate_id) == certificates.end())
  {
    certificates.emplace(get_self(), addentry);
  }
  else
  {
    certificates.modify(certificates.find(certificate_id), get_self(), addentry);
  }
}

void mock_suite::mock_retirement_table(eosio::name const & account)
{
  retirement_table retirement(get_self(), get_self().value);
  auto addentry = [&](auto & entry) { entry = retirement_t(account);};
  if(retirement.begin() == retirement.end())
  {
    retirement.emplace(get_self(), addentry);
  }
  else
  {
    retirement.modify(retirement.begin(), get_self(), addentry);
  }
}

#endif
