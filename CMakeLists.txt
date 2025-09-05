cmake_minimum_required(VERSION 3.10)
project(CodeMap VERSION 0.1.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Include directories
include_directories(${CMAKE_SOURCE_DIR}/include)

# Source files for the core library
set(CORE_SOURCES
    src/codemap_types.cpp
    src/json_exporter.cpp
)

# Create static library
add_library(codemap_core STATIC ${CORE_SOURCES})

# Test executables
add_executable(test_codemap_types tests/test_codemap_types.cpp src/codemap_types.cpp)
add_executable(test_json_exporter tests/test_json_exporter.cpp src/json_exporter.cpp src/codemap_types.cpp)

# Set test output directory
set_target_properties(test_codemap_types test_json_exporter
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/tests
)

# Custom target to build all tests
add_custom_target(tests DEPENDS test_codemap_types test_json_exporter)

# Print build configuration
message(STATUS "CodeMap Configuration:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")