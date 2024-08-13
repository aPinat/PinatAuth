FROM mcr.microsoft.com/dotnet/sdk:8.0.303@sha256:fdab91b56672072a804683ffbdfbe00c0957e5dfc9112d73b430176315591ce7 AS build
WORKDIR /src

COPY ["*.sln", "."]
COPY ["PinatAuth/PinatAuth.csproj", "PinatAuth/"]
RUN dotnet restore

COPY ["PinatAuth/", "PinatAuth/"]
WORKDIR "/src/PinatAuth"
RUN dotnet build -c Release --no-restore

FROM build AS publish
RUN dotnet publish -c Release --no-build -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0.7@sha256:3deda593cf10581cbacfa16a1fbb090353d14beaa65adca4611c7c7a458d66b0
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "PinatAuth.dll"]
