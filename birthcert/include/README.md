# Class explanation

The `birthcert.hpp`, `retirement_contract.hpp`, and `certificate.hpp` are the 3 classes that are actually required to get the smart contract to run in production mode.

The `mock_suite.hpp` class allows you to bypass all normal checks and create a table entry for the retirement_contract and certificate tables.

The `test_suite.hpp` class allows you to call actions to access individual functions of the system

The `mock_retire.hpp` class creates a mocked version of the retirement contract, so that you can send inline actions to it without having to worry about whether or not the retirement class itself can handle those actions.
