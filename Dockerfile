FROM mcr.microsoft.com/dotnet/sdk:9.0.201@sha256:712ffb3919c095da6129ba5ed9d0e7660ab45b966140819d1d58e081bef64293 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:9.0.3@sha256:4f0ad314f83e6abeb6906e69d0f9c81a0d2ee51d362e035c7d3e6ac5743f5399
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
