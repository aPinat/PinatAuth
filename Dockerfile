FROM mcr.microsoft.com/dotnet/sdk:8.0.403@sha256:b38da1961b1358940c634560747e09ef8047234e66c71033f19ac2e777f60240 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:9.0.0@sha256:372b16214ae67e3626a5b1513ade4a530eae10c172d56ce696163b046565fa46
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
