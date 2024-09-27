FROM mcr.microsoft.com/dotnet/sdk:8.0.402@sha256:df188b6cb642450d83d3d857a992bbbef248212fd456dcb9ae582ddd1bb96dce AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.8@sha256:30d8619d9a4f68508d9b17fc2088e857e629d3f9ceaaf57c22d6747f7326d89e
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
