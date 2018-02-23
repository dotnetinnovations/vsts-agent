FROM microsoft/dotnet-framework-build:latest

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /BuildAgent

COPY ./script.ps1 ./

RUN wget -Uri https://aka.ms/vs/15/release/vs_community.exe -OutFile vs_community.exe; \
    ./vs_community.exe --all --passive --wait; \
    ./vs_community.exe update --all --passive --wait

CMD ./script.ps1
