project(birthcertusa)
project(mockretire)

set(EOSIO_WASM_OLD_BEHAVIOR "Off")
find_package(eosio.cdt)

add_contract( birthcertusa birthcertusa birthcertusa.cpp )
target_include_directories( birthcertusa PUBLIC ${CMAKE_SOURCE_DIR}/../include )
target_include_directories( birthcertusa PUBLIC ${CMAKE_SOURCE_DIR}/../../retirementus/include )
target_ricardian_directory( birthcertusa ${CMAKE_SOURCE_DIR}/../ricardian )

add_contract( birthcertusa birthcertusa_local birthcertusa.cpp test_suite.cpp mock_suite.cpp )
target_include_directories( birthcertusa_local PUBLIC ${CMAKE_SOURCE_DIR}/../include )
target_include_directories( birthcertusa_local PUBLIC ${CMAKE_SOURCE_DIR}/../../retirementus/include )
target_compile_definitions( birthcertusa_local PUBLIC LOCAL )
target_ricardian_directory( birthcertusa_local ${CMAKE_SOURCE_DIR}/../ricardian )

add_contract( mockretire mockretire mockretire.cpp )
target_include_directories( mockretire PUBLIC ${CMAKE_SOURCE_DIR}/../include )
target_compile_definitions( mockretire PUBLIC LOCAL )
target_ricardian_directory( mockretire ${CMAKE_SOURCE_DIR}/../ricardian )
