#!/bin/bash
# Build script for Linux Ubuntu 64-bit
echo "Building TodoWebAPI for Linux (x64)..."
dotnet publish -c Release -r linux-x64 --self-contained true
if [ $? -eq 0 ]; then
    echo "Build completed successfully"
    echo "Output files are in: bin/Release/net8.0/linux-x64/publish/"
else
    echo "Build failed"
    exit 1
fi