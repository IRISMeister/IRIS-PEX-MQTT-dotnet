#!/bin/bash
mkdir build
cp -fR /source2/* ./build
dotnet tool install --global Apache.Avro.Tools --version 1.11.3
cat << \EOF >> ~/.bashrc
# Add .NET Core SDK tools
export PATH="$PATH:/root/.dotnet/tools"
EOF
export PATH="$PATH:/root/.dotnet/tools"
dotnet restore build/MQTT.sln
dotnet publish -c debug -o /app build/MQTT.sln
echo "/app/myapp to run"