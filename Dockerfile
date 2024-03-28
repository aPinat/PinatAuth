FROM mcr.microsoft.com/dotnet/sdk:8.0.203@sha256:9bb0d97c4361cc844f225c144ac2adb2b65fabfef21f95caedcf215d844238fe AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.3@sha256:9470bf16cb8566951dfdb89d49a4de73ceb31570b3cdb59059af44fe53b19547
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
