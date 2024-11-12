FROM mcr.microsoft.com/dotnet/sdk:8.0.403@sha256:cab0284cce7bc26d41055d0ac5859a69a8b75d9a201cd226999f4f00cc983f13 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.10@sha256:14e7bcca42c06d03423cdbc8544b8b8abc18228488d03a27f530605af3efaf77
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
