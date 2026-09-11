$ErrorActionPreference = 'Stop'
$addonRoot = Split-Path $PSScriptRoot -Parent
$addonName = 'EllesmereUIKeybindAliases'
$tocPath = Join-Path $addonRoot "$addonName.toc"
$versionLine = Get-Content -LiteralPath $tocPath | Where-Object { $_ -match '^## Version: ([0-9A-Za-z.-]+)$' }
if (-not $versionLine -or $versionLine.Count -gt 1) { throw 'Expected one valid TOC version.' }
$version = ([regex]::Match($versionLine, '^## Version: ([0-9A-Za-z.-]+)$')).Groups[1].Value
$distPath = Join-Path $addonRoot 'dist'
New-Item -ItemType Directory -Force -Path $distPath | Out-Null
$archivePath = Join-Path $distPath "$addonName-$version.zip"
Add-Type -AssemblyName System.IO.Compression.FileSystem
$files = @("$addonName.toc", 'Runtime.lua', 'OptionsIntegration.lua', 'Media/Icon.tga')
foreach ($file in $files) {
    if (-not (Test-Path -LiteralPath (Join-Path $addonRoot $file) -PathType Leaf)) { throw "Missing addon file: $file" }
}
$stream = [IO.File]::Open($archivePath, [IO.FileMode]::Create)
$archive = [IO.Compression.ZipArchive]::new($stream, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in $files) {
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, (Join-Path $addonRoot $file), "$addonName/$file") | Out-Null
    }
} finally {
    $archive.Dispose()
    $stream.Dispose()
}
Write-Output $archivePath
