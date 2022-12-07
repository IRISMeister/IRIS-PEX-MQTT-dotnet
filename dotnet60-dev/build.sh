#!/bin/bash
cp -fR /source2/* .
cp -fR lib mylib1/
dotnet tool install --global Apache.Avro.Tools --version 1.11.0
dotnet restore 
dotnet publish -c debug -o /app
echo "/app/myapp to run"