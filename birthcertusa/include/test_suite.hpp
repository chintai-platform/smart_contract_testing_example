#if LOCAL

#ifndef BIRTHCERTUSA_TEST_SUITE
#define BIRTHCERTUSA_TEST_SUITE

#include "birthcertusa.hpp"

class [[eosio::contract("birthcertusa")]] test_suite : public birthcertusa
{
  public:
    test_suite(eosio::name receiver, eosio::name code, eosio::datastream< const char * > ds) : birthcertusa(receiver, code, ds) {}
    [[eosio::action("testvalidate")]] void test_validate(eosio::name const & account, std::string const & full_name, eosio::time_point const & date_of_birth);
    [[eosio::action("testinsert")]] void test_insert(uint64_t const certificate_id, eosio::name const & account, std::string const & full_name, eosio::time_point const & date_of_birth);
    [[eosio::action("testretdate")]] void test_set_retirement_date(eosio::name const & account, eosio::time_point const & retirement_date);
    [[eosio::action("testcalcret")]] void test_calculate_retirement_date(eosio::time_point const & date_of_birth);
};

#endif

#endif
