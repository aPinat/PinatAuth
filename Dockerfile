FROM mcr.microsoft.com/dotnet/sdk:8.0.402@sha256:b6333c015432da2dd392b8a865bba4e76e9d39d105d65e72b485cf92bcf71316 AS build
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
