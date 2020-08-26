#ifndef AUTHORITY
#define AUTHORITY

class [[ eosio::table("authority"), eosio::contract("retirementus") ]] authority_t
{
  private:
    eosio::name account;
  public:
    authority_t(){}
    authority_t(eosio::name const & _account) : account(_account){}

    uint64_t primary_key() const { return 0; }

    eosio::name get_account() const { return account; }
    void set_account(eosio::name const & _account){ account = _account; }

    EOSLIB_SERIALIZE( authority_t, (account) )
};

typedef eosio::multi_index< eosio::name("authority"), authority_t > authority_table;

#endif
