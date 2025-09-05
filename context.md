# CodeMap Project Context

## Current Phase: Phase 1 Complete → Phase 2 Starting

### ✅ Phase 1 Accomplishments
- **Project structure** created at `/mnt/c/dev/CodeMap/Repo`
- **Core data structures** defined (FunctionNode, FunctionGraph)
- **Contract interfaces** established with PROTECTED CONTRACT markers:
  - `include/codemap_types.h` - Core data structures
  - `include/parser.h` - Parser interface and C++ parser class
  - `include/graph_builder.h` - Graph builder class
  - `include/json_exporter.h` - JSON serialization
- **Comprehensive tests** created with PROTECTED TEST markers:
  - `tests/test_codemap_types.cpp` - Tests for core types
  - `tests/test_json_exporter.cpp` - Tests for JSON functionality
- **Implementation stubs** with passing tests:
  - `src/codemap_types.cpp` - FunctionGraph implementation
  - `src/json_exporter.cpp` - JSON export implementation
- **Build system** configured with CMake
- **Test runners** created (`run_tests.bat` and `run_tests.sh`)
- **GitHub Actions protection** enforcing immutable contracts and tests
- **Documentation** updated (README.md, DEVELOPMENT_PLAN.md)

### 🚧 Phase 2: Parser (Backend) - IN PROGRESS

#### Next Steps:
1. Install libclang dependencies
2. Create `src/parser.cpp` implementing the CppParser class
3. Create `tests/test_parser.cpp` with PROTECTED TEST marker
4. Implement function detection:
   - Parse C++ files using libclang
   - Extract function definitions
   - Identify function calls
   - Mark missing/external callees

### 🔒 Protection Status
- **Protected Contracts**: All headers in `include/` are immutable
- **Protected Tests**: All tests in `tests/` are immutable  
- **GitHub Actions**: Automatically blocks modifications to protected files
- **Modifiable**: Only `src/*.cpp` implementation files can be changed

### 📋 Key Design Decisions
- **Contract-first development**: Interfaces defined before implementation
- **Test-driven development**: Tests written against contracts
- **CMake** for cross-platform build support
- **libclang** for C++ parsing (Phase 2)
- **JSON** as intermediate format for visualization
- **Webview** for future interactive UI (Phase 4)
- **Strict separation**:
  - `/mnt/c/dev/CodeMap/Repo` - permanent project files
  - `/mnt/c/dev/CodeMap/Scratch` - temporary work area

### 🎯 Project Vision
CodeMap will be a visual call graph generator that:
- Scans source code to find all functions
- Maps how functions call each other across files
- Highlights issues (missing functions, stubs, dead code)
- Provides interactive visualization for code understanding

### 📊 Test Status
- ✅ All Phase 1 tests passing
- ✅ `test_codemap_types` - Full coverage of core types
- ✅ `test_json_exporter` - JSON export working (import stubbed)

### 🔄 Repository Status
- GitHub: https://github.com/mugonmuydesk/CodeMap
- Latest commit: GitHub Actions protection implementation
- All contracts and tests are protected from modification
- Ready for Phase 2 implementation work