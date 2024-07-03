FROM mcr.microsoft.com/dotnet/sdk:8.0.302-1@sha256:3189e564f19e016a43838a46609fc81349f07322fdf6bc3299bd13f0dca9e647 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.6@sha256:72bd33dd8f9829cf9681f0a6bc4b43972ec4860a9560ad2b9f4872b548af0add
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
