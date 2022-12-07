#!/bin/bash
mkdir /Sample
cd /Sample
dotnet new sln
mkdir -p mylib/ClassLibrary ; cd mylib/ClassLibrary
dotnet new classlib
dotnet sln ../../Sample.sln add ClassLibrary.csproj
dotnet add package Apache.Avro --version 1.11.0

cd ../..
mkdir -p myapp/ClassLibraryTest && cd myapp/ClassLibraryTest
dotnet new console
dotnet sln ../../Sample.sln add ClassLibraryTest.csproj
dotnet add reference ../../mylib/ClassLibrary/ClassLibrary.csproj

cd ../..
dotnet sln list

dotnet restore 
dotnet publish -c debug -o /app
echo "/app/myapp to run"