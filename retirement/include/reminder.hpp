#ifndef REMINDER
#define REMINDER

class [[eosio::table("reminder"), eosio::contract("retirement")]] reminder_t
{
  private:
    eosio::name account;
    eosio::time_point retirement_date;
  public:
    reminder_t(){}
    reminder_t(eosio::name const & _account, eosio::time_point const & _retirement_date) : account(_account), retirement_date(_retirement_date){}
    
    uint64_t primary_key() const {return account.value;}

    EOSLIB_SERIALIZE( reminder_t, (account)(retirement_date) );
};

typedef eosio::multi_index< eosio::name("reminders"), reminder_t > reminders_table;

#endif
