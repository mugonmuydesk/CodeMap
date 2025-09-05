# Windows Release Guide for CodeMap

## Overview

CodeMap provides self-contained Windows releases that bundle all required LLVM/libclang dependencies. Users can simply download, extract, and run without installing LLVM separately.

## Release Structure

```
codemap-windows-x64/
├── codemap.exe           # Main executable
├── libclang.dll          # Core libclang library (required)
├── LLVM-C.dll           # LLVM C API (if needed)
├── LLVM-17.dll          # LLVM runtime (version-specific)
├── frontend/            # Web visualization files
├── README.md            # Documentation
└── bundle-manifest.txt  # List of bundled dependencies
```

## Building a Windows Release

### Prerequisites

- Visual Studio 2022 with C++ workload
- CMake 3.12 or higher
- LLVM 17 or 18 (for building only)
- PowerShell 5.1 or higher

### Manual Build Process

1. **Install LLVM** (for development):
```powershell
# Using Chocolatey
choco install llvm --version=18.1.8

# Or download from: https://github.com/llvm/llvm-project/releases
```

2. **Build CodeMap**:
```powershell
# Configure
cmake -B build -S . `
  -G "Visual Studio 17 2022" `
  -A x64 `
  -DCMAKE_BUILD_TYPE=Release `
  -DLLVM_DIR="C:\Program Files\LLVM\lib\cmake\llvm" `
  -DClang_DIR="C:\Program Files\LLVM\lib\cmake\clang"

# Build
cmake --build build --config Release
```

3. **Bundle Dependencies**:
```powershell
# Use the bundling script
.\scripts\bundle-windows-deps.ps1 `
  -ExePath "build\bin\Release\codemap.exe" `
  -OutputDir "release-windows" `
  -LLVMPath "C:\Program Files\LLVM" `
  -Verbose
```

4. **Validate Bundle**:
```powershell
# Validate the bundle
.\scripts\validate-windows-bundle.ps1 `
  -BundleDir "release-windows" `
  -Strict
```

5. **Create Distribution**:
```powershell
# Add frontend and docs
Copy-Item -Recurse frontend release-windows\
Copy-Item README.md release-windows\

# Create ZIP
Compress-Archive -Path release-windows\* `
  -DestinationPath codemap-v1.0.0-windows-x64.zip
```

### Automated CI/CD Build

The GitHub Actions workflow automatically builds and bundles Windows releases:

1. **Trigger**: Push a tag starting with `v` (e.g., `v1.0.0`)
2. **Process**: 
   - Downloads and installs LLVM 17
   - Builds CodeMap with Visual Studio
   - Bundles all dependencies
   - Creates ZIP archive
   - Uploads to GitHub Releases

## DLL Bundling Details

### Core Dependencies

The bundling script (`scripts/bundle-windows-deps.ps1`) automatically identifies and copies:

1. **libclang Dependencies**:
   - `libclang.dll` - Core parsing library (required)
   - `LLVM-C.dll` - LLVM C API
   - `LLVM-17.dll` or `LLVM-18.dll` - Version-specific runtime
   - `LLVM.dll` - Core LLVM library

2. **MSVC Runtime** (optional):
   - `msvcp140.dll`
   - `vcruntime140.dll`
   - `vcruntime140_1.dll`

### Dependency Detection

The script uses multiple methods to find dependencies:

1. **dumpbin** (if Visual Studio is installed):
```powershell
dumpbin /DEPENDENTS codemap.exe
```

2. **Manual search** in common locations:
   - `C:\Program Files\LLVM\bin`
   - `C:\LLVM\bin`
   - System directories

### Handling Missing Dependencies

- **System DLLs**: Automatically skipped (Windows provides these)
- **MSVC Runtime**: Can be bundled or users install VC++ Redistributable
- **Optional DLLs**: Logged but don't fail the build

## Troubleshooting

### Common Issues

1. **"libclang.dll not found" error**:
   - Ensure libclang.dll is in the same directory as codemap.exe
   - Check bundle-manifest.txt for missing DLLs

2. **"VCRUNTIME140.dll missing" error**:
   - Install Visual C++ Redistributable: https://aka.ms/vs/17/release/vc_redist.x64.exe
   - Or bundle the runtime DLLs

3. **"Entry point not found" errors**:
   - Version mismatch between libclang.dll and codemap.exe
   - Rebuild with matching LLVM version

### Validation Steps

Run the validation script to check your bundle:

```powershell
.\scripts\validate-windows-bundle.ps1 -BundleDir "path\to\bundle"
```

This checks for:
- Required executables and DLLs
- Frontend files
- Documentation
- Bundle integrity

## User Installation

For end users, installation is simple:

1. Download `codemap-windows-x64.zip` from GitHub Releases
2. Extract to any location
3. Open Command Prompt or PowerShell
4. Run:
```cmd
codemap.exe --help
codemap.exe C:\path\to\your\project
```

No LLVM installation required!

## Version Compatibility

| CodeMap Version | LLVM Version | libclang Version |
|----------------|--------------|------------------|
| 1.0.x          | 17.0.6       | 17.0.6          |
| 1.1.x          | 18.1.8       | 18.1.8          |

## Script Reference

### bundle-windows-deps.ps1

Comprehensive DLL bundling script with features:
- Automatic dependency detection
- Recursive DLL discovery
- MSVC runtime handling
- Manifest generation
- Bundle testing

**Usage**:
```powershell
.\scripts\bundle-windows-deps.ps1 `
  -ExePath "path\to\codemap.exe" `
  -OutputDir "output\directory" `
  -LLVMPath "C:\Program Files\LLVM" `
  -Verbose
```

### validate-windows-bundle.ps1

Bundle validation script that checks:
- Executable presence and functionality
- Critical DLL dependencies
- Optional components
- Bundle statistics

**Usage**:
```powershell
.\scripts\validate-windows-bundle.ps1 `
  -BundleDir "path\to\bundle" `
  -Strict
```

## Best Practices

1. **Always validate** bundles before release
2. **Test on clean Windows** installations
3. **Document LLVM version** used for building
4. **Include manifest** listing all bundled DLLs
5. **Provide fallback** instructions for VC++ Redistributable

## Support

If users encounter issues:
1. Check bundle-manifest.txt for missing dependencies
2. Run validation script
3. Report issues at: https://github.com/mugonmuydesk/CodeMap/issues