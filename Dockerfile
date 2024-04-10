FROM mcr.microsoft.com/dotnet/sdk:8.0.203@sha256:249a78aa4ce22ab872d0dff0490a6389e7bc087d2c080c4ffc7569b49cf0e23b AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.4@sha256:d83ae48d7782b0dbcf077829cdb11b9b9beeb5f8d99bd27cc88c8e02572c6f53
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
