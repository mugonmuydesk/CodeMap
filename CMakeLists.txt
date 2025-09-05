cmake_minimum_required(VERSION 3.10)
project(CodeMap VERSION 0.1.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Find libclang
find_path(LIBCLANG_INCLUDE_DIR clang-c/Index.h
    PATHS /usr/lib/llvm-18/include /usr/lib/llvm/18/include /usr/include
)

find_library(LIBCLANG_LIBRARY
    NAMES clang libclang clang-18
    PATHS /usr/lib/llvm-18/lib /usr/lib/x86_64-linux-gnu /usr/lib /usr/local/lib
)

if(NOT LIBCLANG_INCLUDE_DIR OR NOT LIBCLANG_LIBRARY)
    message(FATAL_ERROR "libclang not found. Please install libclang-dev")
endif()

message(STATUS "Found libclang: ${LIBCLANG_LIBRARY}")
message(STATUS "libclang include: ${LIBCLANG_INCLUDE_DIR}")

# Include directories
include_directories(${CMAKE_SOURCE_DIR}/include)
include_directories(${LIBCLANG_INCLUDE_DIR})

# Source files for the core library
set(CORE_SOURCES
    src/codemap_types.cpp
    src/json_exporter.cpp
    src/parser.cpp
    src/graph_builder.cpp
)

# Create static library
add_library(codemap_core STATIC ${CORE_SOURCES})
target_link_libraries(codemap_core ${LIBCLANG_LIBRARY})

# Test executables
add_executable(test_codemap_types tests/test_codemap_types.cpp src/codemap_types.cpp)
add_executable(test_json_exporter tests/test_json_exporter.cpp src/json_exporter.cpp src/codemap_types.cpp)
add_executable(test_parser tests/test_parser.cpp)
target_link_libraries(test_parser codemap_core ${LIBCLANG_LIBRARY} stdc++fs)
add_executable(test_graph_builder tests/test_graph_builder.cpp)
target_link_libraries(test_graph_builder codemap_core ${LIBCLANG_LIBRARY} stdc++fs)

# Set test output directory
set_target_properties(test_codemap_types test_json_exporter test_parser test_graph_builder
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/tests
)

# Custom target to build all tests
add_custom_target(tests DEPENDS test_codemap_types test_json_exporter test_parser test_graph_builder)

# Print build configuration
message(STATUS "CodeMap Configuration:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")