# Changelog

All notable changes to CodeMap will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-09-05

### Added
- Comprehensive Windows DLL bundling system for self-contained releases
- `scripts/bundle-windows-deps.ps1` - Automated DLL detection and bundling script
- `scripts/validate-windows-bundle.ps1` - Bundle validation and testing script
- `docs/WINDOWS_RELEASE.md` - Complete Windows release documentation
- Bundle manifest generation for tracking bundled dependencies
- Automatic MSVC runtime detection and bundling

### Changed
- Enhanced GitHub Actions Windows workflow with improved DLL bundling
- Windows releases are now fully self-contained (no LLVM installation required)
- Improved error handling and validation in release process
- Updated release notes to indicate self-contained packages

### Fixed
- Windows DLL dependency issues that required manual LLVM installation
- Missing DLL detection in CI/CD pipeline
- Release package validation before publishing

## [1.0.1] - 2025-09-04

### Added
- GitHub Actions CI/CD pipeline for automated builds
- Multi-platform support (Windows with MSVC, Linux with GCC)
- Automated release creation from version tags
- Build status badges in README

### Changed
- Improved build configuration for Windows and Linux
- Updated CMake configuration for better LLVM detection

## [1.0.0] - 2025-09-03

### Added
- Initial release of CodeMap
- C++ parsing with libclang-18
- Interactive web visualization with Cytoscape.js
- Function call graph generation
- Stub and missing function detection
- JSON import/export functionality
- Command-line interface
- Demo mode with sample data
- Comprehensive test suite (73 tests)
- Contract-first development with protected interfaces

### Features
- Analyzes C++ projects to generate call graphs
- Color-coded visualization (implemented, stub, missing, external)
- Multiple graph layouts (hierarchical, circle, grid)
- Interactive filtering and search
- Module grouping by source file
- Export to PNG and JSON formats
- Cross-platform support (Linux, Windows)

[1.0.2]: https://github.com/mugonmuydesk/CodeMap/releases/tag/v1.0.2
[1.0.1]: https://github.com/mugonmuydesk/CodeMap/releases/tag/v1.0.1
[1.0.0]: https://github.com/mugonmuydesk/CodeMap/releases/tag/v1.0.0