FROM mcr.microsoft.com/dotnet/sdk:8.0.400@sha256:33085056163f9e7b384979d2e769661d1572f63afcee032817c0ae715255342a AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.8@sha256:38178966094e8ac38ac3377fa4195cbf63e9aef4030f5e62d2810f8a5df769e4
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
