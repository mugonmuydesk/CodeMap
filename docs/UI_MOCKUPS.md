# CodeMap UI Mockups

## User Journey: From Launch to Visualization

### Step 1: Launch App
```
C:\Tools\CodeMap> codemap.exe
```

➡️ Instead of dumping text, a window opens with a friendly GUI.

### Step 2: Main Window
```
+----------------------------------------------------------+
| CodeMap v1.0.0                                            |
|-----------------------------------------------------------|
| [ Select Project ] [ Open Recent ▼ ] [ Demo Mode ]        |
|                                                           |
| ┌──────────────────────────────────────────────────────┐  |
| | Welcome to CodeMap                                    | |
| |                                                      | |
| | - Visualize function calls in your C++ project       | |
| | - Supports JSON import & demo mode                   | |
| |                                                      | |
| | [ Drag & Drop a folder here to start ]               | |
| └──────────────────────────────────────────────────────┘  |
|                                                           |
| Status: Idle                                              |
+----------------------------------------------------------+
```

### Step 3: User Selects Project

They either:
- Click **[Select Project]**
- Or drag a folder in.

### Step 4: Analysis in Progress
```
+----------------------------------------------------------+
| CodeMap v1.0.0                                            |
|-----------------------------------------------------------|
| Project: C:\dev\MyProject                                 |
|                                                           |
| [ Cancel Analysis ]                                       |
|                                                           |
| ┌──────────────────────────────────────────────────────┐  |
| | Analyzing project…                                   | |
| |                                                      | |
| | Files scanned: 23 / 180                              | |
| | Functions found: 312                                 | |
| | Calls discovered: 1241                               | |
| |                                                      | |
| | [■■■■■■■■■■■■■··························] 47%        | |
| └──────────────────────────────────────────────────────┘  |
|                                                           |
| Status: Parsing C:\dev\MyProject\src\foo.cpp              |
+----------------------------------------------------------+
```

### Step 5: Visualization Loaded
```
+----------------------------------------------------------+
| CodeMap v1.0.0 - Project Graph                           |
|-----------------------------------------------------------|
| [ File View ] [ Function Graph ] [ Export ▼ ]            |
|                                                           |
| ┌──────────────────────────────────────────────────────┐  |
| |   ◯ main()                                           | |
| |     │                                                | |
| |     ├──▶ initConfig()                                | |
| |     ├──▶ parseArgs()                                 | |
| |     │      └──▶ printUsage()                         | |
| |     └──▶ run()                                       | |
| |            ├──▶ doThingA()                           | |
| |            ├──▶ doThingB()                           | |
| |            └──▶ finalize()                           | |
| └──────────────────────────────────────────────────────┘  |
|                                                           |
| Status: Graph generated successfully                      |
+----------------------------------------------------------+
```

Graph is interactive:
- Zoom, pan, click nodes for details.

## Additional UI States

### Error State
```
+----------------------------------------------------------+
| CodeMap v1.0.0                                            |
|-----------------------------------------------------------|
| Project: C:\dev\InvalidProject                            |
|                                                           |
| [ Try Again ] [ Select Different Project ]               |
|                                                           |
| ┌──────────────────────────────────────────────────────┐  |
| | ⚠️ Error                                              | |
| |                                                      | |
| | No C++ files found in the selected directory.        | |
| |                                                      | |
| | Please select a directory containing:                | |
| | - .cpp, .cc, .cxx source files                      | |
| | - .h, .hpp, .hxx header files                       | |
| └──────────────────────────────────────────────────────┘  |
|                                                           |
| Status: Error - No C++ files found                        |
+----------------------------------------------------------+
```

### Settings Panel
```
+----------------------------------------------------------+
| CodeMap v1.0.0 - Settings                                |
|-----------------------------------------------------------|
| [← Back to Graph ]                                       |
|                                                           |
| ┌──────────────────────────────────────────────────────┐  |
| | Parser Settings                                      | |
| | ───────────────                                     | |
| | □ Include system headers                             | |
| | ☑ Parse inline functions                             | |
| | ☑ Follow includes recursively                        | |
| |                                                      | |
| | Display Settings                                     | |
| | ────────────────                                    | |
| | Layout: [Hierarchical ▼]                            | |
| | Node Size: [•••••••···] 70%                        | |
| | Edge Width: [••••·····] 40%                        | |
| |                                                      | |
| | [ Save Settings ] [ Reset to Defaults ]             | |
| └──────────────────────────────────────────────────────┘  |
|                                                           |
| Status: Settings                                          |
+----------------------------------------------------------+
```

### Recent Projects Menu
```
+----------------------------------------------------------+
| CodeMap v1.0.0                                            |
|-----------------------------------------------------------|
| [ Select Project ] [ Open Recent ▼ ] [ Demo Mode ]        |
|                    ┌─────────────────────────────┐       |
|                    | Recent Projects             |       |
|                    | ─────────────────────────   |       |
|                    | 1. C:\dev\MyProject         |       |
|                    | 2. C:\work\ClientApp        |       |
|                    | 3. D:\repos\GameEngine      |       |
|                    | 4. C:\dev\TestLib           |       |
|                    | ─────────────────────────   |       |
|                    | Clear Recent                |       |
|                    └─────────────────────────────┘       |
|                                                           |
| [ Drag & Drop a folder here to start ]                   |
|                                                           |
| Status: Idle                                              |
+----------------------------------------------------------+
```

## Component Details

### Toolbar Buttons
- **Select Project**: Opens native file picker dialog
- **Open Recent**: Dropdown with recently analyzed projects
- **Demo Mode**: Loads sample data for demonstration
- **File View**: Shows file-based grouping of functions
- **Function Graph**: Shows call graph visualization (default)
- **Export**: Dropdown with PNG, JSON, SVG options

### Status Bar
Shows current operation:
- `Idle` - Waiting for user action
- `Parsing C:\path\to\file.cpp` - Currently analyzing file
- `Graph generated successfully` - Analysis complete
- `Error - [description]` - Something went wrong

### Progress Indicators
- File counter: `Files scanned: 23 / 180`
- Function counter: `Functions found: 312`
- Call counter: `Calls discovered: 1241`
- Progress bar: Visual percentage with filled blocks

### Interactive Graph Features
- **Click node**: Show function details in sidebar
- **Double-click node**: Collapse/expand children
- **Right-click node**: Context menu (Go to source, Find usages)
- **Scroll**: Zoom in/out
- **Drag canvas**: Pan around
- **Drag node**: Reposition (if not using automatic layout)