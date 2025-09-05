# CodeMap

*A visual call graph generator that maps how your project's functions connect.*

CodeMap scans your source files, finds functions, and shows how they call each other in an interactive graph. Each function appears as a box, and arrows show the flow of calls across files and modules. Missing, stubbed, or external calls are highlighted so you can spot wiring issues at a glance.

## ✨ Features

- **Function call graph**: Visualize how functions connect across your project
- **Cross-file mapping**: See calls within a file or across modules
- **Stub & TODO detection**: Highlights unimplemented or placeholder functions
- **Dead-end spotting**: Quickly find functions that never get called
- **Interactive graph**: Zoom, pan, and filter by file or module
- **Local app**: Runs with C++ and webview, no browser/server setup needed

## 🚀 Getting Started

### Prerequisites

- C++17 (or later) compiler
- CMake 3.12 or higher
- (Future) libclang for C++ parsing
- (Future) Webview library for UI

### Build

```bash
# Clone the repository
git clone https://github.com/mugonmuydesk/CodeMap.git
cd /mnt/c/dev/CodeMap/Repo

# Create build directory
mkdir build && cd build

# Configure with CMake
cmake ..

# Build the project
cmake --build .

# Run tests (Windows)
cd ..
cmd.exe /c run_tests.bat

# Run tests (Linux/WSL)
./run_tests.sh
```

## 📁 Project Structure

```
/mnt/c/dev/CodeMap/Repo/
├── include/                # Header files (PROTECTED CONTRACTS)
│   ├── codemap_types.h    # Core data structures
│   ├── parser.h           # Parser interface
│   ├── graph_builder.h    # Graph builder
│   └── json_exporter.h    # JSON serialization
├── src/                   # Implementation files
│   ├── codemap_types.cpp  # Core types implementation
│   └── json_exporter.cpp  # JSON export/import
├── tests/                 # Unit tests (PROTECTED TESTS)
│   ├── test_codemap_types.cpp
│   └── test_json_exporter.cpp
├── .github/               # GitHub Actions workflows
│   └── workflows/
│       └── protect-contracts.yml
├── CMakeLists.txt        # Build configuration
├── run_tests.bat         # Windows test runner
├── run_tests.sh          # Linux/WSL test runner
├── DEVELOPMENT_PLAN.md   # Development roadmap
├── FILES.md              # Complete file index
└── context.md            # Current project state
```

## 🔒 Contract Protection

This project uses a contract-first development approach:
- **Header files** in `include/` are marked as `PROTECTED CONTRACT`
- **Test files** in `tests/` are marked as `PROTECTED TEST`
- GitHub Actions automatically blocks any changes to protected files
- Only implementation files in `src/` can be modified

## 🎯 Current Status

**Phase 1: Skeleton & Contracts** ✅ COMPLETED
- Core data structures defined
- Contract interfaces established
- Test framework operational
- GitHub Actions protection active

**Phase 2: Parser (Backend)** 🚧 IN PROGRESS
- Implementing C++ parser with libclang
- Function detection and call analysis

## 📊 Usage (Coming Soon)

Once complete, CodeMap will work like this:

```bash
# Analyze a C++ project
./codemap /path/to/your/project

# This will:
# 1. Scan all source files
# 2. Extract function definitions and calls
# 3. Build the call graph
# 4. Open interactive visualization
```

### Visual Indicators

The graph will use colors to highlight function status:
- 🟢 **Green**: Fully implemented functions
- 🟡 **Yellow**: Stub functions (TODO, NotImplemented)
- 🔴 **Red**: Missing functions (called but not defined)
- ⚫ **Grey**: External library calls

## 📖 Documentation

- **[`README.md`](/mnt/c/dev/CodeMap/Repo/README.md)** - This file: project overview
- **[`DEVELOPMENT_PLAN.md`](/mnt/c/dev/CodeMap/Repo/DEVELOPMENT_PLAN.md)** - Detailed development workflow and phases
- **[`FILES.md`](/mnt/c/dev/CodeMap/Repo/FILES.md)** - Complete index of all project files
- **[`context.md`](/mnt/c/dev/CodeMap/Repo/context.md)** - Current development state and progress

## 🤝 Contributing

This project follows strict contract protection:
1. **Read all documentation first** - Start with [`context.md`](/mnt/c/dev/CodeMap/Repo/context.md) which lists required reading
2. Contracts and tests are immutable once marked as protected
3. Only implementations in `src/` can be modified
4. All changes must pass existing tests
5. See [`DEVELOPMENT_PLAN.md`](/mnt/c/dev/CodeMap/Repo/DEVELOPMENT_PLAN.md) for the full workflow

## 📄 License

[License information to be added]

## 📧 Contact

Project repository: https://github.com/mugonmuydesk/CodeMap