#!/bin/bash
dotnet restore 
dotnet publish -c debug -o /app
echo "/app/ClassLibraryTest to run"
