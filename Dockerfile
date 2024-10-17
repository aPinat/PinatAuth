FROM mcr.microsoft.com/dotnet/sdk:8.0.403@sha256:ff705b99a06144190e2638f8ede64a753915df5ea27fff55f58d0eb5f7054b0b AS build
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
