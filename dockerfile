# Usa la imagen base de .NET 5.0 SDK para compilar la aplicaci�n
FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 61157

# Usa la imagen de SDK para compilar la aplicaci�n
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src

# Copia los archivos de la soluci�n y restaura las dependencias
COPY ["NutritionalAdvice.sln", "."]
COPY ["NutritionalAdvice.Domain/NutritionalAdvice.Domain.csproj", "NutritionalAdvice.Domain/"]
COPY ["NutritionalAdvice.Application/NutritionalAdvice.Application.csproj", "NutritionalAdvice.Application/"]
COPY ["NutritionalAdvice.Infrastructure/NutritionalAdvice.Infrastructure.csproj", "NutritionalAdvice.Infrastructure/"]
COPY ["NutritionalAdvice.Test/NutritionalAdvice.Test.csproj", "NutritionalAdvice.Test/"]
COPY ["NutritionalAdvice.WebApi/NutritionalAdvice.WebApi.csproj", "NutritionalAdvice.WebApi/"]

# Restaura los paquetes NuGet
RUN dotnet restore "NutritionalAdvice.sln"

# Copia todo el c�digo fuente
COPY . .

# Compila la soluci�n
WORKDIR "/src/NutritionalAdvice.WebApi"
RUN dotnet build "NutritionalAdvice.WebApi.csproj" -c Release -o /app/build

# Publica la aplicaci�n
FROM build AS publish
RUN dotnet publish "NutritionalAdvice.WebApi.csproj" -c Release -o /app/publish

# Crea la imagen final
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "NutritionalAdvice.WebApi.dll"]