# CodeMap – UI Development Plan

## 📚 Related Documentation

- **[`README.md`](/mnt/c/dev/CodeMap/Repo/README.md)** – Project overview and features
- **[`FILES.md`](/mnt/c/dev/CodeMap/Repo/FILES.md)** – Complete file index
- **[`context.md`](/mnt/c/dev/CodeMap/Repo/context.md)** – Current project state
- **[`UI_MOCKUPS.md`](/mnt/c/dev/CodeMap/Repo/docs/UI_MOCKUPS.md)** – Visual mockups of the GUI flow

## 📋 Workflow (strict)

Always work in:
- `/mnt/c/dev/CodeMap/Repo` → permanent project files (pushed to GitHub)
- `/mnt/c/dev/CodeMap/Scratch` → temporary files (never pushed/pulled)

### Step Transition Protocol

When progressing between workflow steps, always announce:
1. **Previous Step Completed** – Quote step number and text from UI_DEVELOPMENT_PLAN.md
2. **Current Step Starting** – Quote step number and text from UI_DEVELOPMENT_PLAN.md
3. **Next Step Preview** – Quote step number and text from UI_DEVELOPMENT_PLAN.md

Example transition announcements:

```
📋 Workflow Progress (from UI_DEVELOPMENT_PLAN.md):
✅ Completed Step 2: "Create tests for contracts" - All 15 UI tests passing
🔄 Starting Step 3: "Add / change code" - Implementing WebView2 main window
⏭️ Next Step 4: "Run tests" - Verify WebView loads HTML with demo graph
```

### Critical Dependency Rule

**NEVER alter the development plan because something isn't installed.**

If a dependency is missing:
1. STOP immediately.
2. Ask the human user to install the dependency.
3. Provide exact installation commands.
4. Wait for confirmation before proceeding.

Example: WebView2 SDK must be installed via NuGet.

## Steps

### 1. Add / change contracts and pseudocode

Contracts live in `/mnt/c/dev/CodeMap/Repo/include/ui/*.h`.

Mark with:
```cpp
// PROTECTED CONTRACT: Do not edit except with explicit approval
```

Define interfaces for:
- `UIController` (backend ↔ WebView bridge)
- `FrontendLoader` (load graph JSON into WebView)
- `ProjectSelector` (handle folder drag/drop or file chooser)

### 2. Create tests for contracts

Tests live in `/mnt/c/dev/CodeMap/Repo/tests/ui/`.

Mark existing tests with `// PROTECTED TEST`.

Provide test scaffolding for:
- WebView loads a demo HTML page.
- `UIController::sendGraphData` correctly passes JSON.
- File chooser / drag-drop events trigger correct backend calls.

### 3. Add / change code

Implement in `/mnt/c/dev/CodeMap/Repo/src/ui/*.cpp`.

Responsibilities:
- Main window (WebView2 host).
- Load local HTML/JS (`frontend/index.html`).
- JS bridge for receiving graph JSON.
- UI events → backend (project scan, open JSON, etc.).

### 4. Run tests

```bash
cd /mnt/c/dev/CodeMap/Repo
./run_tests.sh    # WSL
cmd.exe /c run_tests.bat   # Windows
```

### 5. Address errors

Fix `.cpp` implementations and helpers until all tests pass.

### 6. Iterate steps 1–5 until all tests pass.

### 7. GitHub Actions contract enforcement

On every push/PR, Actions check for `// PROTECTED CONTRACT` and `// PROTECTED TEST` markers.

If markers appear in diff → fail the job.

### 8. Push to GitHub

Push repo changes.
Publish release with correct version tag.

### 9. Download .exe

Save to:
```
/mnt/c/dev/Releases/CodeMap/<version>/
```

### 10. Clear Scratch

Wipe `/mnt/c/dev/CodeMap/Scratch/`.

### 11. Update documentation

- Update `FILES.md` with new UI files.
- Update `context.md` with current UI state.
- Push docs to GitHub.

## 🎨 Architecture (UI-specific)

### Frontend (HTML/JS/CSS)

- **Location**: `/mnt/c/dev/CodeMap/Repo/frontend/`
- Uses **Cytoscape.js** for graph visualisation.
- **Layout**:
  - Toolbar (Open Project, Load JSON, Settings).
  - Graph canvas.
  - Sidebar (function details).
  - Progress bar (analysis progress).

### Backend ↔ UI Bridge

- WebView2 JS ↔ C++ bridge.
- `postMessage` → C++ for file selection.
- `sendGraphData(json)` → injects JSON into JS.

### UX Flow

See **[UI_MOCKUPS.md](docs/UI_MOCKUPS.md)** for detailed visual flow.

1. User launches CodeMap → WebView2 window opens.
2. Selects folder or JSON.
3. Backend parses → generates graph JSON.
4. JSON sent to frontend → graph renders automatically.

## 🧪 Testing Plan (UI-specific)

### Unit tests:
- `UIController` mock → verifies JSON is passed.
- `ProjectSelector` mock → verifies folder path is returned.

### Integration test:
- Run `codemap.exe --demo-ui` → launches WebView showing demo graph.

### Automation:
- `run_tests_ui.sh` (Linux/WSL).
- `run_tests_ui.bat` (Windows).

## 🚀 Implementation Phases

### Phase 1: Minimal GUI (v1.1.0)
- Basic WebView2 window
- Load existing frontend HTML
- File open dialog
- Auto-open browser fallback

### Phase 2: Full Integration (v1.2.0)
- Progress bars during analysis
- Recent projects list
- Drag & drop support
- Settings persistence

### Phase 3: Native Experience (v2.0.0)
- Embedded graph visualization
- Native menus and shortcuts
- Multi-tab support
- Project management features