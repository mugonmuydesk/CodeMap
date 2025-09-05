param(
    [Parameter(Mandatory=$true)]
    [string]$BundleDir,
    
    [switch]$Strict
)

$exitCode = 0
$errors = @()
$warnings = @()
$info = @()

function Write-Result {
    param([string]$Message, [string]$Level = "INFO")
    $symbol = switch($Level) {
        "ERROR" { "❌" }
        "WARNING" { "⚠️" }
        "SUCCESS" { "✅" }
        default { "ℹ️" }
    }
    $color = switch($Level) {
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "Cyan" }
    }
    Write-Host "$symbol $Message" -ForegroundColor $color
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "CodeMap Windows Bundle Validator" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if bundle directory exists
if (!(Test-Path $BundleDir)) {
    Write-Result "Bundle directory not found: $BundleDir" "ERROR"
    exit 1
}

Write-Result "Validating bundle at: $BundleDir" "INFO"
Write-Host ""

# 1. Check for main executable
$exePath = Join-Path $BundleDir "codemap.exe"
if (Test-Path $exePath) {
    Write-Result "Main executable found: codemap.exe" "SUCCESS"
    $exeSize = (Get-Item $exePath).Length / 1MB
    Write-Result "Executable size: $([math]::Round($exeSize, 2)) MB" "INFO"
} else {
    Write-Result "Main executable not found: codemap.exe" "ERROR"
    $errors += "Missing codemap.exe"
    $exitCode = 1
}

# 2. Check for critical LLVM/libclang DLLs
Write-Host ""
Write-Host "Checking critical DLLs..." -ForegroundColor White

$criticalDLLs = @{
    "libclang.dll" = "Core libclang library (REQUIRED)"
}

foreach ($dll in $criticalDLLs.Keys) {
    $dllPath = Join-Path $BundleDir $dll
    if (Test-Path $dllPath) {
        Write-Result "$dll - $($criticalDLLs[$dll])" "SUCCESS"
        $dllSize = (Get-Item $dllPath).Length / 1MB
        Write-Result "  Size: $([math]::Round($dllSize, 2)) MB" "INFO"
    } else {
        Write-Result "$dll - $($criticalDLLs[$dll])" "ERROR"
        $errors += "Missing critical DLL: $dll"
        $exitCode = 1
    }
}

# 3. Check for additional LLVM DLLs that might be needed
Write-Host ""
Write-Host "Checking additional LLVM DLLs..." -ForegroundColor White

$additionalDLLs = @{
    "LLVM-C.dll" = "LLVM C API"
    "LLVM-17.dll" = "LLVM 17 runtime"
    "LLVM-18.dll" = "LLVM 18 runtime"
    "LLVM.dll" = "LLVM core library"
}

$foundAdditional = 0
foreach ($dll in $additionalDLLs.Keys) {
    $dllPath = Join-Path $BundleDir $dll
    if (Test-Path $dllPath) {
        Write-Result "$dll - $($additionalDLLs[$dll])" "SUCCESS"
        $foundAdditional++
    } else {
        if ($Strict) {
            Write-Result "$dll - $($additionalDLLs[$dll])" "WARNING"
            $warnings += "Optional DLL not found: $dll"
        }
    }
}

if ($foundAdditional -eq 0) {
    Write-Result "No additional LLVM DLLs found (may cause runtime issues)" "WARNING"
    $warnings += "No additional LLVM DLLs bundled"
}

# 4. Check for MSVC Runtime
Write-Host ""
Write-Host "Checking MSVC Runtime..." -ForegroundColor White

$msvcDLLs = @("msvcp140.dll", "vcruntime140.dll", "vcruntime140_1.dll")
$msvcFound = 0

foreach ($dll in $msvcDLLs) {
    $dllPath = Join-Path $BundleDir $dll
    if (Test-Path $dllPath) {
        Write-Result "$dll found" "SUCCESS"
        $msvcFound++
    }
}

if ($msvcFound -eq 0) {
    Write-Result "No MSVC runtime DLLs bundled (users need VC++ Redistributable)" "WARNING"
    $info += "Users will need to install Visual C++ Redistributable"
} elseif ($msvcFound -lt $msvcDLLs.Count) {
    Write-Result "Partial MSVC runtime bundled ($msvcFound/$($msvcDLLs.Count))" "WARNING"
}

# 5. Check for frontend files
Write-Host ""
Write-Host "Checking frontend files..." -ForegroundColor White

$frontendPath = Join-Path $BundleDir "frontend"
if (Test-Path $frontendPath) {
    $htmlFiles = Get-ChildItem -Path $frontendPath -Filter "*.html" -Recurse
    $jsFiles = Get-ChildItem -Path $frontendPath -Filter "*.js" -Recurse
    $cssFiles = Get-ChildItem -Path $frontendPath -Filter "*.css" -Recurse
    
    Write-Result "Frontend directory found" "SUCCESS"
    Write-Result "  HTML files: $($htmlFiles.Count)" "INFO"
    Write-Result "  JavaScript files: $($jsFiles.Count)" "INFO"
    Write-Result "  CSS files: $($cssFiles.Count)" "INFO"
} else {
    Write-Result "Frontend directory not found" "WARNING"
    $warnings += "Missing frontend files"
}

# 6. Check for documentation
Write-Host ""
Write-Host "Checking documentation..." -ForegroundColor White

$readmePath = Join-Path $BundleDir "README.md"
if (Test-Path $readmePath) {
    Write-Result "README.md found" "SUCCESS"
} else {
    Write-Result "README.md not found" "WARNING"
}

$manifestPath = Join-Path $BundleDir "bundle-manifest.txt"
if (Test-Path $manifestPath) {
    Write-Result "Bundle manifest found" "SUCCESS"
    Write-Result "Manifest contents:" "INFO"
    Get-Content $manifestPath | Select-Object -First 5 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }
}

# 7. Test executable (if possible)
if (Test-Path $exePath) {
    Write-Host ""
    Write-Host "Testing executable..." -ForegroundColor White
    
    try {
        $testOutput = & $exePath --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Result "Executable test passed (--version)" "SUCCESS"
            Write-Result "Version output: $testOutput" "INFO"
        } else {
            Write-Result "Executable test failed (exit code: $LASTEXITCODE)" "ERROR"
            $errors += "Executable test failed"
            $exitCode = 1
        }
    } catch {
        Write-Result "Could not run executable test: $_" "WARNING"
        $warnings += "Could not test executable"
    }
}

# 8. Calculate total bundle size
Write-Host ""
Write-Host "Bundle Statistics..." -ForegroundColor White

$totalSize = 0
Get-ChildItem -Path $BundleDir -Recurse -File | ForEach-Object {
    $totalSize += $_.Length
}
$totalSizeMB = [math]::Round($totalSize / 1MB, 2)

Write-Result "Total bundle size: $totalSizeMB MB" "INFO"

$dllCount = (Get-ChildItem -Path $BundleDir -Filter "*.dll").Count
Write-Result "Total DLLs bundled: $dllCount" "INFO"

# Summary
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Validation Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

if ($errors.Count -eq 0) {
    Write-Result "No critical errors found!" "SUCCESS"
} else {
    Write-Result "$($errors.Count) critical error(s) found:" "ERROR"
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

if ($warnings.Count -gt 0) {
    Write-Result "$($warnings.Count) warning(s):" "WARNING"
    $warnings | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}

if ($info.Count -gt 0) {
    Write-Result "Additional information:" "INFO"
    $info | ForEach-Object { Write-Host "  - $_" -ForegroundColor Cyan }
}

Write-Host ""
if ($exitCode -eq 0) {
    Write-Result "Bundle validation PASSED" "SUCCESS"
} else {
    Write-Result "Bundle validation FAILED" "ERROR"
}

exit $exitCode