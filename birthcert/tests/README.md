# Test structure

The command to run all tests is called `run_all_tests.sh`

The reusable scripts are stored in `global.sh`

The nodeos instance will use the `config.ini` file supplied in this folder

All the tests are then split into their respective folders, you can also add multiple files to each folder and call each file by using `source MY_FILENAME`in the appropriate script.

The reports folder will contain a report for your tests, showing how long each test took, whether it passes or failed, and what the failure message was. This is useful for continuous integration that has built in test report analysis tools
