FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
ENV ISC_PACKAGE_INSTALLDIR /usr/irissys
ENV GWLIBDIR lib
ENV ISC_LIBDIR ${ISC_PACKAGE_INSTALLDIR}/dev/dotnet/bin/net6.0

WORKDIR /source
COPY --from=containers.intersystems.com/intersystems/iris-community:2023.1.1.380.0 $ISC_LIBDIR/* $GWLIBDIR/

# copy project files
COPY . .

# make an empty folder
RUN mkdir mylib1/lib 
RUN dotnet restore 

RUN dotnet publish -c release -o /app

# final stage/image
FROM mcr.microsoft.com/dotnet/runtime:6.0

ENV DOTNET_CLI_TELEMETRY_OPTOUT 1

WORKDIR /app

# copy GatewayLinux
COPY --from=build /source/lib ./

# copy published files
COPY --from=build /app ./

ENV PORT 55556

#for debug
#CMD sleep 10000
CMD ./InterSystems.Data.GatewayLinux $PORT netgw.log netgw 0.0.0.0
