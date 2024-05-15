FROM mcr.microsoft.com/dotnet/sdk:8.0.300@sha256:935902ef9eee58a9226b906e3d6ff1b2abaca240c9d5b4ac8dca9943b26c8f33 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.4@sha256:acb8f8e836ae3ba350d37edcfdfafb7bb6e583630672faadecf873d4921f3b8d
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
