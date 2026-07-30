param(
    [string]$Icarus = "iverilog",
    [string]$Vvp = "vvp"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$buildDirectory = Join-Path $PSScriptRoot ".build"
New-Item -ItemType Directory -Force -Path $buildDirectory | Out-Null

if (-not (Get-Command $Icarus -ErrorAction SilentlyContinue)) {
    throw "Icarus Verilog was not found. Install it or pass -Icarus <path>."
}
if (-not (Get-Command $Vvp -ErrorAction SilentlyContinue)) {
    throw "The Icarus vvp runtime was not found. Install it or pass -Vvp <path>."
}

$rtl = Get-ChildItem -Path $projectRoot -Recurse -Filter *.v |
    Where-Object { $_.DirectoryName -notlike "$PSScriptRoot*" } |
    ForEach-Object { $_.FullName }
$tests = Get-ChildItem -Path $PSScriptRoot -Filter "tb_*.v" | Sort-Object Name

foreach ($test in $tests) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($test.Name)
    $output = Join-Path $buildDirectory "$name.out"
    & $Icarus -g2012 -s $name -o $output $test.FullName $rtl
    if ($LASTEXITCODE -ne 0) { throw "Compilation failed: $name" }
    & $Vvp $output
    if ($LASTEXITCODE -ne 0) { throw "Simulation failed: $name" }
}

Write-Host "All $($tests.Count) testbenches passed."
