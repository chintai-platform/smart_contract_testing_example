# How to compile

In order to compile the code:

```
cmake .. && make -j
```

Upon successfuly compilation, the build script will try to run the tests, and they may well fail on your computer if you haven't set everything up in advance properly. You need the following programs installed:
- `bc`
- `jq`
- `curl`
- `nodeos`

If I have missed any programs off from this list, let me know.

You also need to have a few environmental variables set. Specifically you need to have:
- `EOSIO_CONTRACTS_DIRECTORY` (Points to the v1.9 of eosio.contracts that you must have installed)
- `EOSIO_OLD_CONTRACTS_DIRECTORY` (Points to the v1.8 of eosio.contracts that you must also have installed)
- `BIRTH_CERTIFICATE_CONTRACT` (Points to the base path of the birthcert smart contract)
- `RETIREMENT_CONTRACT` (Points to the base path of the retirement smart contract)
