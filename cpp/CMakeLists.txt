cmake_minimum_required(VERSION 3.19)

project(HeroismOfWar VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(NOT DEFINED GODOT_CPP_DIR)
    set(GODOT_CPP_DIR "$ENV{GODOT_CPP_DIR}")
endif()

if(NOT GODOT_CPP_DIR)
    message(FATAL_ERROR "Set GODOT_CPP_DIR to the Godot C++ bindings directory before building.")
endif()

find_package(mongocxx REQUIRED)
find_package(bsoncxx REQUIRED)

include_directories(
    ${GODOT_CPP_DIR}/include
    ${GODOT_CPP_DIR}/gen/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

link_directories(${GODOT_CPP_DIR}/bin)

add_library(heroism_of_war SHARED
    src/register_types.cpp
    src/heroism_war_node.cpp
    src/mongo_service.cpp
)

target_link_libraries(heroism_of_war
    PRIVATE
    godot-cpp
    mongo::mongocxx_shared
    mongo::bsoncxx_shared
)

set_target_properties(heroism_of_war PROPERTIES
    PREFIX "lib"
    OUTPUT_NAME "heroism_of_war"
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
)
