#!/bin/bash
dotnet tool install --global Apache.Avro.Tools --version 1.11.3
cat << \EOF >> ~/.bashrc
# Add .NET Core SDK tools
export PATH="$PATH:/root/.dotnet/tools"
EOF
export PATH="$PATH:/root/.dotnet/tools"
avrogen -s /share/SimpleClass.avsc ./gen --namespace foo:dc
cp gen/dc/SimpleClass.cs /source2/mylib1/