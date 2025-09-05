# CodeMap – Development Plan

## 📚 Related Documentation

- **[`README.md`](/mnt/c/dev/CodeMap/Repo/README.md)** - Project overview and features
- **[`FILES.md`](/mnt/c/dev/CodeMap/Repo/FILES.md)** - Complete file index
- **[`context.md`](/mnt/c/dev/CodeMap/Repo/context.md)** - Current project state

## Workflow (strict)

Always work in:
- `/mnt/c/dev/CodeMap/Repo` → permanent project files (pushed to GitHub)
- `/mnt/c/dev/CodeMap/Scratch` → temporary files (never pushed/pulled)

### Critical Dependency Rule
**NEVER alter the development plan because something isn't installed.** If a required dependency is missing:
1. STOP immediately - do not create alternative implementations
2. Ask the human user to install the missing dependency
3. Provide the exact installation command(s) they need to run
4. Wait for confirmation that the dependency is installed before proceeding
5. The original plan and architecture must be followed - missing dependencies are not a reason to change the design

## Steps

1. **Add / change contracts and pseudocode**
   - Contracts live in headers (`/mnt/c/dev/CodeMap/Repo/include/*.h`).
   - Mark contract headers with:
     ```cpp
     // PROTECTED CONTRACT: Do not edit except with explicit approval
     ```
   - From this point, the header is locked.

2. **Create tests for contracts**
   - Tests live in `/mnt/c/dev/CodeMap/Repo/tests/`.
   - Existing tests are protected (marked with `// PROTECTED TEST`).
   - New test files may be added, but not modifications to protected ones.
   - Provide/update `run_tests.bat` and `run_tests.sh`.

3. **Add / change code**
   - Implement in `/mnt/c/dev/CodeMap/Repo/src/*.cpp`.
   - Helpers may include private `.h` files, but never alter protected contracts/tests.

4. **Run tests**
   ```bash
   cd /mnt/c/dev/CodeMap/Repo
   ./run_tests.sh    # WSL  
   # or
   cmd.exe /c run_tests.bat   # Windows
   ```

5. **Address errors**
   - Fix `.cpp` implementations and internal helpers until all tests pass.

6. **Iterate steps 1–5 until all tests pass.**

6.5. **GitHub Actions contract enforcement**
   - On every push and pull request, GitHub Actions checks whether protected files in `/mnt/c/dev/CodeMap/Repo/include/` or `/mnt/c/dev/CodeMap/Repo/tests/` contain the markers `// PROTECTED CONTRACT` or `// PROTECTED TEST`.
   - If those markers appear in the diff, the job fails.
   - A failed job blocks merging.
   - This ensures contracts and tests remain immutable once marked as protected.

7. **Push to GitHub**
   - Push repo changes.
   - Publish release with correct version tag.

8. **Download .exe**
   - Save to:
     ```
     /mnt/c/dev/Releases/CodeMap/<version>/
     ```

9. **Clear Scratch**
   - Wipe `/mnt/c/dev/CodeMap/Scratch/`.

10. **Update documentation**
    - Update `/mnt/c/dev/CodeMap/Repo/FILES.md` with any new files or changes.
    - Update `/mnt/c/dev/CodeMap/Repo/context.md` with current project state.
    - Ensure all documentation cross-references are accurate.
    - Push all documentation updates to GitHub.
    - Suggest clearing context.

## Architecture

### 1. Core Components

#### Parser
- Extracts function definitions and calls.
- Start: C++ with libclang.
- Later: extend with tree-sitter for Python/JS.

#### Graph Builder
- Translates parser output into FunctionGraph.
- Node = function, Edge = call.
- Supports JSON export.

#### Frontend (Webview)
- C++ webview loads local HTML/JS.
- Renders graph using Cytoscape.js (or vis.js).

#### App Shell
- C++ executable.
- Controls scanning, graph building, JSON export, and frontend display.

### 2. Development Order

#### Phase 1: Skeleton & Contracts
Define contracts in headers (`/mnt/c/dev/CodeMap/Repo/include/`):
- Parser API:
  ```cpp
  FunctionGraph parseProject(const std::string& path);
  ```
- Graph structure:
  ```cpp
  struct FunctionNode {
    std::string name;
    std::string file;
    int line;
    bool isStub;
    bool isMissing;
    bool isExternal;
  };
  
  struct FunctionGraph {
    std::vector<FunctionNode> nodes;
    std::vector<std::pair<int,int>> edges; // caller → callee (node indices)
  };
  ```
- JSON export:
  ```cpp
  std::string toJSON(const FunctionGraph& graph);
  ```
- Frontend loader:
  ```cpp
  void loadGraph(const std::string& jsonString);
  ```

#### Phase 2: Parser (Backend)
- Implement minimal C++ parser (libclang).
- Detect functions + calls.
- Mark missing callees.

#### Phase 3: Graph Builder
- Build FunctionGraph from parser output.
- Add JSON exporter.
- Unit test correctness.

#### Phase 4: Frontend
- Create C++ webview container.
- Load HTML/JS with Cytoscape.
- Render demo graph.
- Hook up JSON input → render real graph.

#### Phase 5: Highlighting & Interactivity
- Node colours:
  - Green = implemented
  - Yellow = stub
  - Red = missing
  - Grey = external
- Tooltip with file + line.
- Click → highlight connected nodes.

#### Phase 6: Integration
- Full pipeline:
  Project → Parse → Graph → JSON → Webview → Visualisation.

#### Phase 7: Packaging & Release
- `.bat` and `.sh` for tests + build.
- Push to GitHub with version tag.
- Publish GitHub Release.
- Download exe to `/mnt/c/dev/Releases/CodeMap/<version>/`.
- Clear Scratch.
- Update FILES.md with final file structure.
- Update context.md with release status.

### 3. Testing Plan

**Unit tests:**
- Parser (functions + calls).
- Graph builder (nodes/edges).
- JSON export (valid, schema-correct).

**Integration test:**
- Sample project → graph matches expected nodes/edges.

**Automation:**
- `run_tests.bat` (Windows).
- `run_tests.sh` (WSL).