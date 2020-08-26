#ifndef RETIREMENT_CONTRACT
#define RETIREMENT_CONTRACT

#include <eosio/eosio.hpp>

class [[eosio::contract("retirementus")]] retirementus : public eosio::contract {
   public:
      using eosio::contract::contract;

      [[eosio::action("authority")]] void set_birthcertusa_authority(eosio::name const & account);
      using set_birthcertusa_authority_action = eosio::action_wrapper<"authority"_n, &retirementus::set_birthcertusa_authority>;

      [[eosio::action("setdate")]] void set_retirement_date(eosio::name const & account, eosio::time_point const & date);
      using set_retirement_date_action = eosio::action_wrapper<"setdate"_n, &retirementus::set_retirement_date>;
};

#endif
