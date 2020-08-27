project(birthcert)
project(mockretire)

set(EOSIO_WASM_OLD_BEHAVIOR "Off")
find_package(eosio.cdt)

add_contract( birthcert birthcert birthcert.cpp )
target_include_directories( birthcert PUBLIC ${CMAKE_SOURCE_DIR}/../include )
target_include_directories( birthcert PUBLIC ${CMAKE_SOURCE_DIR}/../../retirement/include )
target_ricardian_directory( birthcert ${CMAKE_SOURCE_DIR}/../ricardian )

add_contract( birthcert birthcert_local birthcert.cpp test_suite.cpp mock_suite.cpp )
target_include_directories( birthcert_local PUBLIC ${CMAKE_SOURCE_DIR}/../include )
target_include_directories( birthcert_local PUBLIC ${CMAKE_SOURCE_DIR}/../../retirement/include )
target_compile_definitions( birthcert_local PUBLIC LOCAL )
target_ricardian_directory( birthcert_local ${CMAKE_SOURCE_DIR}/../ricardian )

add_contract( mockretire mockretire mockretire.cpp )
target_include_directories( mockretire PUBLIC ${CMAKE_SOURCE_DIR}/../include )
target_compile_definitions( mockretire PUBLIC LOCAL )
target_ricardian_directory( mockretire ${CMAKE_SOURCE_DIR}/../ricardian )
