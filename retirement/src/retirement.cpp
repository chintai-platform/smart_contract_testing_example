#include <retirement.hpp>
#include "authority.hpp"
#include "reminder.hpp"

void retirement::set_retirement_date(eosio::name const & account, eosio::time_point const & retirement_date)
{
  authority_table authority(get_self(), get_self().value);
  eosio::check(authority.begin() != authority.end(), "Reminder can  not be set when no authority exists");
  require_auth(authority.begin()->get_account());

  reminders_table reminders(get_self(), get_self().value);
  auto addentry = [&](auto & entry){entry = reminder_t(account, retirement_date);};
  if(reminders.find(account.value) == reminders.end())
  {
    reminders.emplace(get_self(), addentry);
  }
  else
  {
    reminders.modify(reminders.find(account.value), get_self(), addentry);
  }
}

void retirement::set_birthcertusa_authority(eosio::name const & account)
{
  require_auth(get_self());
  authority_table table(get_self(), get_self().value);
  auto addentry = [&](auto & entry){entry.set_account(account);};
  if(table.begin() == table.end())
  {
    table.emplace(get_self(), addentry);
  }
  else
  {
    table.modify(table.begin(), get_self(), addentry);
  }
}
