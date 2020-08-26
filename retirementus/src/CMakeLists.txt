project(retirementus)

set(EOSIO_WASM_OLD_BEHAVIOR "Off")
find_package(eosio.cdt)

add_contract( retirementus retirementus retirementus.cpp )
target_include_directories( retirementus PUBLIC ${CMAKE_SOURCE_DIR}/../include )
target_ricardian_directory( retirementus ${CMAKE_SOURCE_DIR}/../ricardian )