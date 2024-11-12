FROM mcr.microsoft.com/dotnet/sdk:8.0.403@sha256:b38da1961b1358940c634560747e09ef8047234e66c71033f19ac2e777f60240 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.10@sha256:3ded9ccf06f222ec934311be4f9facda83d144331c028340e3a694733cad7d4b
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
