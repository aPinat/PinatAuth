FROM mcr.microsoft.com/dotnet/sdk:9.0.300@sha256:90872f8e7f1fd2b93989b81fb7f152c3bef4fe817470a3227abaa18c873dba60 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:9.0.5@sha256:d5507d8292fb2469ec0b9913f3cd4bb8d5a014bd6dc00c33fd4c4e7310229f07
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
