FROM mcr.microsoft.com/dotnet/core/sdk:2.1 AS build

ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
ENV ISC_PACKAGE_INSTALLDIR /usr/irissys
ENV GWLIBDIR lib
ENV ISC_LIBDIR ${ISC_PACKAGE_INSTALLDIR}/dev/dotnet/bin/Core21

WORKDIR /source
# Can't use 2021.1... It lacks InterSystems.EnsLib.*
# MQTTService3.cs(7,49): error CS0234: The type or namespace name 'EnsLib' does not exist in the namespace 'InterSystems' (are you missing an assembly reference?) [/source/mylib1/mylib1.csproj]
COPY --from=store/intersystems/iris-community:2021.2.0.617.0 $ISC_LIBDIR/*.nupkg $GWLIBDIR/

# copy csproj and restore as distinct layers
#COPY *.csproj ./
COPY . .
RUN cp -fR $GWLIBDIR mylib1/
RUN dotnet restore mylib1/mylib1.csproj && dotnet restore myapp/myapp.csproj 

# copy and publish app and libraries
#COPY . .
RUN dotnet publish -c release -o /app

# final stage/image
FROM mcr.microsoft.com/dotnet/core/runtime:2.1

ENV DOTNET_CLI_TELEMETRY_OPTOUT 1

WORKDIR /app
COPY --from=build /app ./

# Configs to start the Gateway Server
RUN cp mylib1.runtimeconfig.json IRISGatewayCore21.runtimeconfig.json && \
    cp mylib1.deps.json IRISGatewayCore21.deps.json

ENV PORT 55556

CMD dotnet IRISGatewayCore21.dll $PORT netgw.log netgw 0.0.0.0
