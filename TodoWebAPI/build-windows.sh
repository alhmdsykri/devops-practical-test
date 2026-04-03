#!/bin/bash
# Build script for Windows 64-bit
echo "Building TodoWebAPI for Windows (x64)..."
dotnet publish -c Release -r win-x64 --self-contained true
if [ $? -eq 0 ]; then
    echo "Build completed successfully"
    echo "Output files are in: bin/Release/net8.0/win-x64/publish/"
else
    echo "Build failed"
    exit 1
fi