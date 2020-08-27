#ifndef BIRTH_CERTIFICATE_CONTRACT
#define BIRTH_CERTIFICATE_CONTRACT

#include "retirement.hpp"

#include <eosio/eosio.hpp>

class [[eosio::contract("birthcert")]] birthcert : public eosio::contract
{
  protected:
    void validate(eosio::name const & account, std::string const & full_name, eosio::time_point const & date_of_birth);
    void create_account(eosio::name const & account);
    void insert(uint64_t const certificate_id, eosio::name const & account, std::string const & full_name, eosio::time_point const & date_of_birth);
    void set_retirement_date(eosio::name const & account, eosio::time_point const & date_of_birth);
    eosio::time_point calculate_retirement_date(eosio::time_point const & date_of_birth);

  public:
    using eosio::contract::contract;

    [[eosio::action("add")]] void add_birth_certificate(uint64_t const certificate_id, eosio::name const & account, std::string const & full_name, eosio::time_point const & date_of_birth);
    using add_action = eosio::action_wrapper<"add"_n, &birthcert::add_birth_certificate>;

    [[eosio::action("setretire")]] void set_retirement_contract(eosio::name const & account);
    using setretire_action = eosio::action_wrapper<"setretire"_n, &birthcert::set_retirement_contract>;
};

#endif
