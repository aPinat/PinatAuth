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

FROM mcr.microsoft.com/dotnet/aspnet:9.0.3@sha256:c013be6e8c5219fa56002ad96aac9d99afcca23a185aadd0a30e9b4f3d6efd8c
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
