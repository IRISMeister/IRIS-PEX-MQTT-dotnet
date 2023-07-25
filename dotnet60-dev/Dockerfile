FROM mcr.microsoft.com/dotnet/sdk:6.0

RUN apt update; apt install vim -y
RUN echo "set clipboard=unnamed,autoselect" >> .vimrc
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
ENV ISC_PACKAGE_INSTALLDIR /usr/irissys
ENV GWLIBDIR lib
ENV ISC_LIBDIR ${ISC_PACKAGE_INSTALLDIR}/dev/dotnet/bin/net6.0
WORKDIR /source
COPY *.sh ./
COPY Sample .
COPY --from=containers.intersystems.com/intersystems/iris-community:2023.1.1.380.0 $ISC_LIBDIR/* $GWLIBDIR/
