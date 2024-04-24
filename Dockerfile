FROM mcr.microsoft.com/dotnet/sdk:8.0.204@sha256:7861b15f318949cf9214d9ad5382b680a0e22e3b8673180707aa0c594ab75656 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.4@sha256:acb8f8e836ae3ba350d37edcfdfafb7bb6e583630672faadecf873d4921f3b8d
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
