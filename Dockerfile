FROM mcr.microsoft.com/dotnet/sdk:8.0.301@sha256:1e0c55b0ae732f333818f13c284a01c0e3a2ec431491e23c0a525f6803895c50 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.5@sha256:516d18718444d5af9cd5a55dc10095c55bfcf96606a15e3d03476d4e67d9139a
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
