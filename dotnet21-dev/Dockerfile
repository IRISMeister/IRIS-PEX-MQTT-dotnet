FROM mcr.microsoft.com/dotnet/core/sdk:2.1

ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
ENV ISC_PACKAGE_INSTALLDIR /usr/irissys
ENV GWLIBDIR lib
ENV ISC_LIBDIR ${ISC_PACKAGE_INSTALLDIR}/dev/dotnet/bin/Core21
# Apache.Avro.Tools is not compatible with netcoreapp2.1 
#RUN dotnet tool install --global Apache.Avro.Tools --version 1.11.0
WORKDIR /source
COPY --from=containers.intersystems.com/intersystems/iris-community:2022.1.0.209.0 $ISC_LIBDIR/*.nupkg $GWLIBDIR/
COPY build.sh .
