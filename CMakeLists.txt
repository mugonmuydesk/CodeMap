cmake_minimum_required(VERSION 3.10)
project(CodeMap VERSION 0.1.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Platform-specific configuration
if(WIN32)
    # Windows-specific settings
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    
    # Try to find LLVM/Clang using CMake packages
    # Try different LLVM installation paths
    if(NOT DEFINED LLVM_DIR)
        # Check LLVM 17/18 paths
        if(EXISTS "C:/LLVM/lib/cmake/llvm")
            set(LLVM_DIR "C:/LLVM/lib/cmake/llvm")
        elseif(EXISTS "C:/Program Files/LLVM/lib/cmake/llvm")
            set(LLVM_DIR "C:/Program Files/LLVM/lib/cmake/llvm")
        elseif(EXISTS "C:/LLVM/cmake")
            set(LLVM_DIR "C:/LLVM/cmake")
        endif()
    endif()
    
    find_package(LLVM CONFIG)
    if(LLVM_FOUND)
        message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
        message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")
        
        include_directories(${LLVM_INCLUDE_DIRS})
        separate_arguments(LLVM_DEFINITIONS_LIST NATIVE_COMMAND ${LLVM_DEFINITIONS})
        add_definitions(${LLVM_DEFINITIONS_LIST})
        
        # Find Clang within LLVM
        if(NOT DEFINED Clang_DIR)
            if(EXISTS "${LLVM_DIR}/../clang")
                set(Clang_DIR "${LLVM_DIR}/../clang")
            elseif(EXISTS "C:/LLVM/lib/cmake/clang")
                set(Clang_DIR "C:/LLVM/lib/cmake/clang")
            endif()
        endif()
        find_package(Clang CONFIG)
        if(Clang_FOUND)
            message(STATUS "Found Clang")
            set(LIBCLANG_LIBRARY clang)
            set(LIBCLANG_INCLUDE_DIR ${LLVM_INCLUDE_DIRS})
        else()
            # Fallback to finding libclang manually on Windows
            find_library(LIBCLANG_LIBRARY
                NAMES libclang clang
                PATHS ${LLVM_LIBRARY_DIR} "C:/Program Files/LLVM/lib" "C:/LLVM/lib"
            )
        endif()
    else()
        # Try to find libclang directly if CMake config not available
        if(DEFINED LIBCLANG_LIBRARY AND DEFINED LIBCLANG_INCLUDE_DIR)
            message(STATUS "Using direct libclang paths")
            message(STATUS "  Library: ${LIBCLANG_LIBRARY}")
            message(STATUS "  Include: ${LIBCLANG_INCLUDE_DIR}")
            include_directories(${LIBCLANG_INCLUDE_DIR})
        else()
            # Last resort: try to find libclang manually
            find_path(LIBCLANG_INCLUDE_DIR clang-c/Index.h
                PATHS "C:/LLVM/include" "C:/Program Files/LLVM/include"
            )
            find_library(LIBCLANG_LIBRARY
                NAMES libclang clang
                PATHS "C:/LLVM/lib" "C:/Program Files/LLVM/lib"
            )
            
            if(LIBCLANG_LIBRARY AND LIBCLANG_INCLUDE_DIR)
                message(STATUS "Found libclang manually")
                message(STATUS "  Library: ${LIBCLANG_LIBRARY}")
                message(STATUS "  Include: ${LIBCLANG_INCLUDE_DIR}")
                include_directories(${LIBCLANG_INCLUDE_DIR})
            else()
                message(FATAL_ERROR "LLVM/Clang not found on Windows. Please install LLVM.")
            endif()
        endif()
    endif()
    
    set(PLATFORM_LIBS ${LIBCLANG_LIBRARY})
else()
    # Linux/Unix configuration (existing code)
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
    
    set(PLATFORM_LIBS ${LIBCLANG_LIBRARY} stdc++fs pthread)
endif()

# Include directories
include_directories(${CMAKE_SOURCE_DIR}/include)
include_directories(${LIBCLANG_INCLUDE_DIR})

# Source files for the core library
set(CORE_SOURCES
    src/codemap_types.cpp
    src/json_exporter.cpp
    src/parser.cpp
    src/graph_builder.cpp
    src/webview_app_simple.cpp
)

# Create static library
add_library(codemap_core STATIC ${CORE_SOURCES})
target_link_libraries(codemap_core ${LIBCLANG_LIBRARY})

# Main executable
add_executable(codemap src/main.cpp)
target_link_libraries(codemap codemap_core ${PLATFORM_LIBS})

# Test executables
add_executable(test_codemap_types tests/test_codemap_types.cpp src/codemap_types.cpp)
add_executable(test_json_exporter tests/test_json_exporter.cpp src/json_exporter.cpp src/codemap_types.cpp)
add_executable(test_parser tests/test_parser.cpp)
target_link_libraries(test_parser codemap_core ${PLATFORM_LIBS})
add_executable(test_graph_builder tests/test_graph_builder.cpp)
target_link_libraries(test_graph_builder codemap_core ${PLATFORM_LIBS})

# Set test output directory
set_target_properties(test_codemap_types test_json_exporter test_parser test_graph_builder
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/tests
)

# Copy frontend files to build directory
file(COPY ${CMAKE_SOURCE_DIR}/frontend DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

# Custom target to build all tests
add_custom_target(tests DEPENDS test_codemap_types test_json_exporter test_parser test_graph_builder)

# Print build configuration
message(STATUS "CodeMap Configuration:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")