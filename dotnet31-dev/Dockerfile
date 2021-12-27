FROM mcr.microsoft.com/dotnet/core/sdk:3.1

ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
ENV ISC_PACKAGE_INSTALLDIR /usr/irissys
ENV GWLIBDIR lib
ENV ISC_LIBDIR ${ISC_PACKAGE_INSTALLDIR}/dev/dotnet/bin/Core21
RUN dotnet tool install --global Apache.Avro.Tools --version 1.11.0
WORKDIR /source
COPY --from=store/intersystems/iris-community:2021.2.0.617.0 $ISC_LIBDIR/*.nupkg $GWLIBDIR/
