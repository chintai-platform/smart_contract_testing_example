project(retirement)

set(EOSIO_WASM_OLD_BEHAVIOR "Off")
find_package(eosio.cdt)

add_contract( retirement retirement retirement.cpp )
target_include_directories( retirement PUBLIC ${CMAKE_SOURCE_DIR}/../include )
target_ricardian_directory( retirement ${CMAKE_SOURCE_DIR}/../ricardian )