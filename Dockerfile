FROM microsoft/dotnet-framework-build:latest

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /BuildAgent

COPY ./script.ps1 ./

CMD ./script.ps1
