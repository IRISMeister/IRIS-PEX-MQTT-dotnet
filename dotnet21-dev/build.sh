#!/bin/bash
cp -fR /source2/* .
mv lib mylib1/
dotnet restore mylib1/mylib1.csproj
dotnet restore myapp/myapp.csproj 
dotnet restore genavro/genavro.csproj
dotnet publish -c debug -o /app
echo "dotnet /app/myapp.dll to run"
