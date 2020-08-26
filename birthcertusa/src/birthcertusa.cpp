#include <birthcertusa.hpp>
#include "certificate.hpp"
#include "retirement.hpp"

#include <eosio/system.hpp>

void birthcertusa::add_birth_certificate(uint64_t const certificate_id, eosio::name const & account, std::string const & full_name, eosio::time_point const & date_of_birth)
{
  require_auth(get_self());
  validate(account, full_name, date_of_birth);
  insert(certificate_id, account, full_name, date_of_birth);
  set_retirement_date(account, date_of_birth);
}

void birthcertusa::validate(eosio::name const & account, std::string const & full_name, eosio::time_point const & date_of_birth)
{
  eosio::check(is_account(account), "The account " + account.to_string() + " does not exist");
  eosio::check(full_name.size() > 0, "The name must not be an empty string");
  eosio::check(date_of_birth < eosio::current_time_point(), "The birth must have happened in the past");
}

void birthcertusa::insert(uint64_t const certificate_id, eosio::name const & account, std::string const & full_name, eosio::time_point const & date_of_birth)
{
  certificates_table certificates(get_self(), get_self().value);
  eosio::check(certificates.find(certificate_id) == certificates.end(), "A certificate with ID " + std::to_string(certificate_id) + " already exists");
  auto addentry = [&](auto & entry)
  {
    entry = certificate_t(certificate_id, account, full_name, date_of_birth);
  };
  certificates.emplace(get_self(), addentry);  
}

void birthcertusa::set_retirement_date(eosio::name const & account, eosio::time_point const & date_of_birth)
{
  eosio::time_point const retirement_date = calculate_retirement_date(date_of_birth);
  eosio::name const retirement_contract = retirement_table(get_self(), get_self().value).require_find(0, "The retirement contract has not been set")->get_account();
  retirementus::set_retirement_date_action(retirement_contract, { get_self(), "active"_n }).send(account, retirement_date);
}

eosio::time_point birthcertusa::calculate_retirement_date(eosio::time_point const & date_of_birth)
{
  return eosio::time_point(eosio::microseconds( (static_cast<int64_t>(date_of_birth.sec_since_epoch()) + 65*365*24*60*60) * 1000000) );
}

void birthcertusa::set_retirement_contract(eosio::name const & account)
{
  require_auth(get_self());
  retirement_table table(get_self(), get_self().value);
  auto addentry = [&](auto & entry){ entry = retirement_t(account); };
  if(table.begin() == table.end())
  {
    table.emplace(get_self(), addentry);
  }
  else
  {
    table.modify(table.begin(), get_self(), addentry);
  }
}
