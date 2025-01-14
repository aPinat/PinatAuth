FROM mcr.microsoft.com/dotnet/sdk:9.0.101@sha256:26d070b5f4f32fbf3223f24cd27c5aef94f9074e54270eca2239b833563f6221 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:9.0.0@sha256:ccbfa267780c99ec81252a8e5133db55aa5325fd4eeeb532d3108bcbdca339b5
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
