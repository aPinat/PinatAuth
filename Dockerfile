FROM mcr.microsoft.com/dotnet/sdk:10.0.102@sha256:25d14b400b75fa4e89d5bd4487a92a604a4e409ab65becb91821e7dc4ac7f81f AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:10.0.2@sha256:1aacc8154bc3071349907dae26849df301188be1a2e1f4560b903fb6275e481a
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
