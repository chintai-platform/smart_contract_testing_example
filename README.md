# Smart Contract Test Examples

This example code consists of two smart contracts. In the theoretical example given here, there are two departments of the government that must coordinate.
The first department stores on-chain the birth certificate information for newly born citizens.
The second department keeps track of when citizens will retire.
When a birth certificate is added to the one contract, it calls an inline action to set the retirement time on the other contract to 65 years after the date of birth.

## How to set up this example

This example assumes you have a working version of `nodeos`, `cleos`, `curl`, and `jq` on your local machine.
You must have a compiled version of `eosio.contracts` in both version 1.8 and version 1.9, as per the instructions for setting up `eosio.cdt`.
You must also create some environmental variables for the location of the two subfolders in this repository, and they must be called `BIRTH_CERTIFICATE_CONTRACT` and `RETIREMENT_CONTRACT` respectively.

### Compiling

To compile the contracts, go into `retirementus/build` and type `cmake .. && make`. This will compile the retirement contract which has no test cases.
When compiling the birth certificate contract, the test cases will automatically run upon compilation success, you can run the tests by going to `birthcertusa/build` and typing `cmake .. && make -j`
