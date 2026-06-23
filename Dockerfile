# syntax=docker/dockerfile:1

# --- Build stage : compile et package le jar Spring Boot ---
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Dépendances d'abord (meilleure mise en cache des layers)
COPY gradlew settings.gradle.kts build.gradle.kts ./
COPY gradle ./gradle
RUN chmod +x gradlew && ./gradlew dependencies --no-daemon || true

# Code source puis build du jar (les tests tournent dans la pipeline CI)
COPY src ./src
RUN ./gradlew bootJar --no-daemon

# --- Runtime stage : image légère avec seulement le JRE ---
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8084
ENTRYPOINT ["java", "-jar", "app.jar"]
