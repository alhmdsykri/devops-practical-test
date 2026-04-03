<# 
Build script for Linux Ubuntu 64-bit
#>

Write-Host "Building TodoWebAPI for Linux (x64)..."
$result = dotnet publish -c Release -r linux-x64 --self-contained true

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build completed successfully"
    Write-Host "Output files are in: bin/Release/net8.0/linux-x64/publish/"
} else {
    Write-Host "Build failed with error code $LASTEXITCODE"
    exit 1
}