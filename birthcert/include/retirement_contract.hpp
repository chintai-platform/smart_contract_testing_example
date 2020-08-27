#ifndef RETIREMENT
#define RETIREMENT

class [[eosio::table("retirecontr"), eosio::contract("birthcert")]] retirement_contract_t
{
  private:
    eosio::name account;
  public:
    retirement_contract_t(){}
    retirement_contract_t(eosio::name const & _account) : account(_account){}

    uint64_t primary_key() const { return 0; }

    eosio::name get_account() const { return account; }

    EOSLIB_SERIALIZE( retirement_contract_t, (account) );
};

typedef eosio::multi_index< eosio::name("retirecontr"), retirement_contract_t > retirement_contract_table;

#endif
