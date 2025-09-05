# CodeMap

A C++ library for analyzing and visualizing function call graphs in source code projects. CodeMap provides tools to parse C++ source files, extract function information, build call graphs, and export the results in various formats including JSON.

## Features

- **Function Analysis**: Extract detailed information about functions including signatures, parameters, return types, and metadata
- **Call Graph Building**: Analyze function calls and build comprehensive call graphs
- **JSON Export/Import**: Serialize and deserialize function graphs to/from JSON format
- **Multiple File Support**: Process individual files or entire directory structures
- **Filtering Options**: Export filtered subsets of the function graph by file, class, or other criteria
- **Statistics**: Generate statistics about the codebase including orphaned functions and circular dependencies
- **Cross-platform**: Works on Windows, Linux, and macOS

## Project Structure

```
C:\dev\CodeMap\Repo\
├── include/                     # Header files
│   ├── codemap_types.h         # Core data structures
│   ├── parser.h                # Parser interfaces
│   ├── graph_builder.h         # Graph building functionality
│   └── json_exporter.h         # JSON serialization
├── src/                        # Implementation files
│   ├── codemap_types.cpp       # Core types implementation
│   └── json_exporter.cpp       # JSON export/import
├── tests/                      # Unit tests
│   ├── test_codemap_types.cpp  # Core types tests
│   └── test_json_exporter.cpp  # JSON exporter tests
├── CMakeLists.txt              # CMake build configuration
├── run_tests.bat               # Test runner script
└── README.md                   # This file
```

## Requirements

- **C++17 compatible compiler** (GCC 7+, Clang 6+, MSVC 2017+)
- **CMake 3.12 or later**
- **Optional**: nlohmann/json library for enhanced JSON support

## Building

### Windows (Visual Studio)

```cmd
# Clone the repository
git clone <repository-url>
cd C:\dev\CodeMap\Repo

# Create build directory
mkdir build
cd build

# Configure with CMake
cmake -G "Visual Studio 16 2019" -A x64 ..

# Build
cmake --build . --config Release
```

### Windows (MinGW/MSYS2)

```bash
# Create build directory
mkdir build && cd build

# Configure and build
cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release ..
make -j4
```

### Linux/macOS

```bash
# Create build directory
mkdir build && cd build

# Configure and build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j4
```

## Usage

### Basic Example

```cpp
#include "codemap/codemap_types.h"
#include "codemap/graph_builder.h"
#include "codemap/json_exporter.h"

using namespace codemap;

int main() {
    // Create a graph builder
    GraphBuilder builder;
    
    // Build function graph from a directory
    auto graph = builder.buildFromDirectory("C:\\dev\\MyProject\\src");
    
    // Export to JSON
    JsonExporter exporter;
    std::string json_output = exporter.exportToJson(*graph);
    
    // Save to file
    exporter.exportToFile(*graph, "function_graph.json");
    
    // Print statistics
    std::cout << "Functions: " << graph->getFunctionCount() << std::endl;
    std::cout << "Calls: " << graph->getCallCount() << std::endl;
    
    return 0;
}
```

### Advanced Configuration

```cpp
// Configure graph builder
GraphBuilderConfig config;
config.include_headers = true;
config.include_source = true;
config.resolve_calls = true;
config.exclude_patterns = {"*test*", "*mock*"};

GraphBuilder builder(config);

// Configure JSON export
JsonExportConfig export_config;
export_config.pretty_print = true;
export_config.include_call_graph = true;
export_config.include_documentation = true;

JsonExporter exporter(export_config);
```

### Filtering and Analysis

```cpp
// Get functions from specific files
auto main_functions = graph->getFunctionsByFile("C:\\dev\\MyProject\\src\\main.cpp");

// Find orphaned functions
auto orphaned = graph->getOrphanedFunctions();

// Detect circular dependencies
auto cycles = graph->findCircularDependencies();

// Export filtered by class
std::vector<std::string> classes = {"MyClass", "OtherClass"};
std::string filtered_json = exporter.exportFilteredByClasses(*graph, classes);
```

## Testing

Run the test suite using the provided batch script:

```cmd
run_tests.bat
```

Or manually with CMake:

```cmd
mkdir build && cd build
cmake -DBUILD_TESTS=ON ..
cmake --build .
ctest --output-on-failure
```

## API Reference

### Core Classes

#### `FunctionNode`
Represents a single function with its metadata:
- `name`: Function name
- `signature`: Full function signature
- `file_path`: Source file path
- `line_number`: Line where function is defined
- `return_type`: Function return type
- `parameters`: Function parameters
- `class_name`: Class name (for methods)
- `namespace_name`: Namespace
- `calls`: Functions this function calls
- `called_by`: Functions that call this function

#### `FunctionGraph`
Manages the complete function graph:
- `addFunction()`: Add a function to the graph
- `addCall()`: Add a call relationship
- `getFunction()`: Retrieve a function by name
- `getAllFunctions()`: Get all functions
- `getCallees()/getCallers()`: Get call relationships
- `getFunctionsByFile()`: Filter by file
- `getFunctionsByClass()`: Filter by class
- `getOrphanedFunctions()`: Find orphaned functions
- `findCircularDependencies()`: Detect cycles

#### `GraphBuilder`
Builds function graphs from source code:
- `buildFromFile()`: Analyze a single file
- `buildFromDirectory()`: Analyze a directory
- `buildFromFiles()`: Analyze multiple files
- Configurable filtering and processing options

#### `JsonExporter`
Handles JSON serialization:
- `exportToJson()`: Export graph to JSON string
- `exportToFile()`: Export graph to JSON file
- `importFromJson()`: Import graph from JSON
- `exportFilteredByFiles()`: Export filtered subset
- `exportStatistics()`: Export graph statistics

## JSON Format

The exported JSON follows this structure:

```json
{
  "metadata": {
    "function_count": 42,
    "call_count": 156,
    "export_timestamp": "2024-01-15T10:30:00"
  },
  "functions": [
    {
      "name": "main",
      "signature": "int main(int argc, char* argv[])",
      "file_path": "C:\\dev\\MyProject\\src\\main.cpp",
      "line_number": 10,
      "return_type": "int",
      "parameters": ["int argc", "char* argv[]"],
      "documentation": "Main entry point"
    }
  ],
  "call_graph": {
    "main": ["init", "process", "cleanup"],
    "process": ["validate", "transform"]
  }
}
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Roadmap

- [ ] Support for additional languages (Python, Java, C#)
- [ ] Visual graph rendering
- [ ] Integration with popular IDEs
- [ ] Advanced metrics and code quality analysis
- [ ] Database backend for large codebases
- [ ] Web-based visualization interface

## Support

For questions, bug reports, or feature requests, please open an issue on GitHub.

## Acknowledgments

- Built with modern C++17
- Uses CMake for cross-platform building
- Optional integration with nlohmann/json for enhanced JSON support