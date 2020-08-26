#ifndef RETIREMENT
#define RETIREMENT

class [[eosio::table("retirement"), eosio::contract("birthcertusa")]] retirement_t
{
  private:
    eosio::name account;
  public:
    retirement_t(){}
    retirement_t(eosio::name const & _account) : account(_account){}

    uint64_t primary_key() const { return 0; }

    eosio::name get_account() const { return account; }

    EOSLIB_SERIALIZE( retirement_t, (account) );
};

typedef eosio::multi_index< eosio::name("retirement"), retirement_t > retirement_table;

#endif
