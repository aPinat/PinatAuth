FROM mcr.microsoft.com/dotnet/sdk:8.0.302@sha256:6ea28da4f1d4a0dadc6a72f723cd35bc6efec5a66846e7acbe3d468827e1dcfa AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.6@sha256:a22d22bcedc67df31bca96e2cde2dbac2e59913f9ec684612d42dff45722bcc5
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
