#ifndef CERTIFICATE
#define CERTIFICATE

class [[eosio::table("certificate"), eosio::contract("birthcert")]] certificate_t
{
  private:
    uint64_t certificate_id;
    eosio::name account;
    std::string full_name;
    eosio::time_point date_of_birth;
  public:
    certificate_t(){}
    certificate_t(uint64_t const _certificate_id, eosio::name const & _account, std::string const & _full_name, eosio::time_point const & _date_of_birth) : certificate_id(_certificate_id), account(_account), full_name(_full_name), date_of_birth(_date_of_birth){}
    
    uint64_t primary_key() const {return certificate_id;}

    EOSLIB_SERIALIZE( certificate_t, (certificate_id)(account)(full_name)(date_of_birth) );
};

typedef eosio::multi_index< eosio::name("certificates"), certificate_t > certificates_table;

#endif
