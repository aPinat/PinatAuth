FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore "PinatAuth/PinatAuth.csproj"
COPY . .
WORKDIR "/src/PinatAuth"
RUN dotnet build "PinatAuth.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "PinatAuth.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
