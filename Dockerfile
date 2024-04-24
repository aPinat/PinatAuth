FROM mcr.microsoft.com/dotnet/sdk:8.0.204@sha256:03476e8b974ca8e5084bf63742d85f04a5f53df0ae37c82d31bae228eb297e6c AS build
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
