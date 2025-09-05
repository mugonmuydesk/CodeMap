param(
    [Parameter(Mandatory=$true)]
    [string]$ExePath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputDir,
    
    [string]$LLVMPath = "C:\Program Files\LLVM",
    
    [switch]$Verbose
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch($Level) {
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Get-DLLDependencies {
    param([string]$FilePath)
    
    $dependencies = @()
    
    # Try dumpbin first (Visual Studio)
    $dumpbinPath = @(
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
    
    if ($dumpbinPath) {
        Write-Log "Using dumpbin to analyze dependencies"
        $output = & (Get-Item $dumpbinPath) /DEPENDENTS $FilePath 2>&1
        $inDependents = $false
        foreach ($line in $output) {
            if ($line -match "Image has the following dependencies") {
                $inDependents = $true
            } elseif ($inDependents -and $line -match "^\s+(.+\.dll)") {
                $dependencies += $matches[1].Trim()
            } elseif ($line -match "^\s+Summary") {
                break
            }
        }
    } else {
        Write-Log "dumpbin not found, using alternative method" "WARNING"
        # Alternative: Use .NET reflection (limited but works for basic cases)
        try {
            $assembly = [System.Reflection.Assembly]::LoadFile($FilePath)
            $referencedAssemblies = $assembly.GetReferencedAssemblies()
            foreach ($ref in $referencedAssemblies) {
                $dependencies += "$($ref.Name).dll"
            }
        } catch {
            Write-Log "Could not analyze dependencies using .NET reflection" "WARNING"
        }
    }
    
    return $dependencies | Select-Object -Unique
}

function Find-DLL {
    param([string]$DLLName)
    
    $searchPaths = @(
        "$LLVMPath\bin",
        "$LLVMPath\lib",
        "${env:ProgramFiles}\LLVM\bin",
        "${env:ProgramFiles(x86)}\LLVM\bin",
        "C:\LLVM\bin",
        "${env:WINDIR}\System32",
        "${env:WINDIR}\SysWOW64",
        $PSScriptRoot,
        (Split-Path -Parent $ExePath)
    )
    
    foreach ($path in $searchPaths) {
        $fullPath = Join-Path $path $DLLName
        if (Test-Path $fullPath) {
            return $fullPath
        }
    }
    
    return $null
}

# Main execution
Write-Log "Starting DLL bundling for: $ExePath"
Write-Log "Output directory: $OutputDir"

# Create output directory if it doesn't exist
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Log "Created output directory"
}

# Copy the executable
$exeName = Split-Path -Leaf $ExePath
$destExe = Join-Path $OutputDir $exeName
Copy-Item $ExePath $destExe -Force
Write-Log "Copied executable to output directory"

# Get primary dependencies
Write-Log "Analyzing DLL dependencies..."
$primaryDeps = Get-DLLDependencies -FilePath $ExePath

# Core LLVM/Clang DLLs that we definitely need
$coreDLLs = @(
    "libclang.dll",
    "LLVM-C.dll",
    "LLVM-18.dll",
    "LLVM-17.dll",
    "LLVM.dll"
)

# Combine with detected dependencies
$allDLLs = ($coreDLLs + $primaryDeps) | Select-Object -Unique

# System DLLs to skip (Windows provides these)
$systemDLLs = @(
    "kernel32.dll", "user32.dll", "gdi32.dll", "advapi32.dll",
    "shell32.dll", "ole32.dll", "oleaut32.dll", "ws2_32.dll",
    "ntdll.dll", "msvcrt.dll", "comctl32.dll", "comdlg32.dll",
    "setupapi.dll", "shlwapi.dll", "winmm.dll", "winspool.drv",
    "rpcrt4.dll", "crypt32.dll", "bcrypt.dll", "ucrtbase.dll"
)

$copiedDLLs = @()
$missingDLLs = @()

foreach ($dll in $allDLLs) {
    # Skip system DLLs
    if ($systemDLLs -contains $dll.ToLower()) {
        if ($Verbose) {
            Write-Log "Skipping system DLL: $dll"
        }
        continue
    }
    
    $dllPath = Find-DLL -DLLName $dll
    if ($dllPath) {
        $destPath = Join-Path $OutputDir $dll
        if (!(Test-Path $destPath)) {
            Copy-Item $dllPath $destPath -Force
            $copiedDLLs += $dll
            Write-Log "Copied: $dll" "SUCCESS"
            
            # Recursively check dependencies of this DLL
            if ($Verbose) {
                $subDeps = Get-DLLDependencies -FilePath $dllPath
                foreach ($subDep in $subDeps) {
                    if (-not ($allDLLs -contains $subDep) -and 
                        -not ($systemDLLs -contains $subDep.ToLower())) {
                        $allDLLs += $subDep
                    }
                }
            }
        } else {
            if ($Verbose) {
                Write-Log "Already exists: $dll"
            }
        }
    } else {
        # Only warn about missing non-MSVC runtime DLLs
        if ($dll -notmatch "^(msvcp|vcruntime|concrt|api-ms-)") {
            $missingDLLs += $dll
            Write-Log "Could not find: $dll" "WARNING"
        }
    }
}

# Handle MSVC Runtime
$msvcDLLs = @("msvcp140.dll", "vcruntime140.dll", "vcruntime140_1.dll")
$msvcFound = 0
foreach ($msvcDLL in $msvcDLLs) {
    $msvcPath = Find-DLL -DLLName $msvcDLL
    if ($msvcPath) {
        Copy-Item $msvcPath (Join-Path $OutputDir $msvcDLL) -Force -ErrorAction SilentlyContinue
        $msvcFound++
    }
}

if ($msvcFound -gt 0) {
    Write-Log "Copied $msvcFound MSVC runtime DLLs" "SUCCESS"
} else {
    Write-Log "MSVC runtime DLLs not found - users may need VC++ Redistributable" "WARNING"
}

# Summary
Write-Log "=== Bundling Complete ===" "SUCCESS"
Write-Log "Copied $($copiedDLLs.Count) DLLs to output directory"
if ($missingDLLs.Count -gt 0) {
    Write-Log "Could not find $($missingDLLs.Count) DLLs (may be optional):" "WARNING"
    $missingDLLs | ForEach-Object { Write-Log "  - $_" "WARNING" }
}

# Create a manifest file
$manifestPath = Join-Path $OutputDir "bundle-manifest.txt"
$manifest = @"
CodeMap Windows Bundle Manifest
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Executable: $exeName
LLVM Path: $LLVMPath

Bundled DLLs:
$($copiedDLLs -join "`n")

Missing DLLs (may be optional):
$($missingDLLs -join "`n")

Note: If the application fails to start, ensure Visual C++ Redistributable is installed.
Download from: https://aka.ms/vs/17/release/vc_redist.x64.exe
"@

$manifest | Out-File -FilePath $manifestPath -Encoding UTF8
Write-Log "Created bundle manifest: $manifestPath"

# Test the bundled executable
Write-Log "Testing bundled executable..."
$testProcess = Start-Process -FilePath $destExe -ArgumentList "--version" -NoNewWindow -Wait -PassThru
if ($testProcess.ExitCode -eq 0) {
    Write-Log "Executable test passed!" "SUCCESS"
} else {
    Write-Log "Executable test failed with exit code: $($testProcess.ExitCode)" "ERROR"
}