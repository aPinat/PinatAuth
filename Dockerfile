FROM mcr.microsoft.com/dotnet/sdk:8.0.401-1@sha256:1e8c6666f3e31f96d22a5c77054589f85078a4850595421c6999395f26e79b9a AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.8@sha256:e935e3424c1043dad7f904240d767c76e0c32a3c9a8bf661c32eac6f29f5ea73
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
