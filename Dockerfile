FROM mcr.microsoft.com/dotnet/sdk:8.0.302-1@sha256:3bc4c8f13482237ab906d38dd9e290b4b1a093a2653ab3c28cca710b46510b9d AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.7@sha256:6c4df091e4e531bb93bdbfe7e7f0998e7ced344f54426b7e874116a3dc3233ff
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
