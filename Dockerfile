FROM mcr.microsoft.com/dotnet/sdk:9.0.303@sha256:670ef9e8eca44c8baa0bd1c229ccde9537064260ef14d54738b7a87916609312 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:9.0.7@sha256:7269109eb94f0f63cb99179a032d697ee06e5873901b7cd611bcba5553257558
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
