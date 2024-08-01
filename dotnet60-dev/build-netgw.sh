#!/bin/bash
mkdir build
cp -fR /netgw/* ./build

dotnet restore build/MQTT.sln
dotnet publish -c debug -o /app build/MQTT.sln
echo "/app/myapp to run"