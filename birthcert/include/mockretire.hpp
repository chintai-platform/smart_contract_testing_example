#if LOCAL

#ifndef MOCK_RETIREMENTUS_CONTRACT
#define MOCK_RETIREMENTUS_CONTRACT

#include <eosio/eosio.hpp>

class [[eosio::contract("mockretire")]] mockretire : public eosio::contract
{
  public:
    using eosio::contract::contract;

    [[eosio::action("authority")]] void set_birthcert_authority(eosio::name const & account);
    [[eosio::action("setdate")]] void set_retirement_date(eosio::name const & account, eosio::time_point const & date);
};

#endif

#endif
