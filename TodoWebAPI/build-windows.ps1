<# 
Build script for Windows 64-bit
#>

Write-Host "Building TodoWebAPI for Windows (x64)..."
$result = dotnet publish -c Release -r win-x64 --self-contained true

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build completed successfully"
    Write-Host "Output files are in: bin/Release/net8.0/win-x64/publish/"
} else {
    Write-Host "Build failed with error code $LASTEXITCODE"
    exit 1
}