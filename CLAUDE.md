# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

This project uses the Gradle wrapper (Kotlin DSL). On Windows use `gradlew.bat`; the examples below use the POSIX `./gradlew`.

- Build: `./gradlew build`
- Run the app: `./gradlew bootRun`
- Run all tests: `./gradlew test`
- Run a single test class: `./gradlew test --tests "com.sfeir.testweb.TestWebApplicationTests"`
- Run a single test method: `./gradlew test --tests "com.sfeir.testweb.TestWebApplicationTests.contextLoads"`

## Runtime

- The app starts on **port 8084** (`server.port` in `src/main/resources/application.yaml`).
- The database is an **in-memory H2** instance (`jdbc:h2:mem:products-db`) — data is wiped on every restart, and the schema is created by Hibernate's auto-DDL.
- The H2 web console is enabled (`spring.h2.console.enabled: true`), reachable at `/h2-console`. Use JDBC URL `jdbc:h2:mem:products-db` to connect.

## Architecture

Spring Boot 4.1.0 application on Java 21. Standard layered JPA structure under `com.sfeir.testweb`:

- `entities/` — JPA `@Entity` classes (e.g. `Product`).
- `repository/` — Spring Data JPA repositories extending `JpaRepository`.
- `web/` — `@RestController` classes (e.g. `ProductController`, which exposes `GET /products` and `GET /products/{id}`).
- `TestWebApplication.java` — the `@SpringBootApplication` entry point.

There is no service layer — controllers inject repositories directly.

### Notable conventions

- **Lombok** is used for entity boilerplate (`@Data`, `@Builder`, `@NoArgsConstructor`, `@AllArgsConstructor`). It is `compileOnly` + `annotationProcessor`, so the IDE must have annotation processing enabled.
- This is **Spring Boot 4.x**, which uses the newer split starter names: `spring-boot-starter-webmvc` (not `spring-boot-starter-web`) and `spring-boot-h2console` for the console. Keep this in mind when adding dependencies — the older artifact names will not resolve.
