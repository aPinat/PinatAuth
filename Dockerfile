FROM mcr.microsoft.com/dotnet/sdk:8.0.401-1@sha256:a364676fedc145cf88caad4bfb3cc372aae41e596c54e8a63900a2a1c8e364c6 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.8@sha256:11d6f2f1d19520b98ee8417c2420a467690e8a0a4b9a6951a124840286536f89
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
