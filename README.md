# test-web

Petite application Spring Boot exposant une API REST de gestion de produits (`Product`), avec une base de données **H2 en mémoire** pré-remplie au démarrage.

## Stack technique

- **Java 21**
- **Spring Boot 4.1.0** (Spring Web MVC, Spring Data JPA)
- **H2** (base en mémoire)
- **Lombok**
- **Gradle** (wrapper, Kotlin DSL)

## Prérequis

- JDK 21
- Aucune installation de Gradle nécessaire : le wrapper (`gradlew` / `gradlew.bat`) s'en charge.

## Démarrer l'application

```bash
# Linux / macOS
./gradlew bootRun

# Windows
gradlew.bat bootRun
```

L'application démarre sur le port **8084**.

## Base de données

- Base **H2 en mémoire** : `jdbc:h2:mem:products-db`.
- Les données sont **recréées à chaque démarrage** (rien n'est persisté sur disque).
- Le schéma est généré automatiquement par Hibernate, puis le fichier
  [`src/main/resources/data.sql`](src/main/resources/data.sql) insère un jeu de
  produits initial (grâce à `spring.jpa.defer-datasource-initialization: true`,
  qui exécute le script après la création des tables).

### Console H2

La console web H2 est activée : <http://localhost:8084/h2-console>

| Champ     | Valeur                      |
|-----------|-----------------------------|
| JDBC URL  | `jdbc:h2:mem:products-db`   |
| User      | `sa`                        |
| Password  | *(vide)*                    |

## API REST

| Méthode | URL              | Description                          |
|---------|------------------|--------------------------------------|
| `GET`   | `/products`      | Liste tous les produits              |
| `GET`   | `/products/{id}` | Récupère un produit par son `id`     |

Exemple :

```bash
curl http://localhost:8084/products
curl http://localhost:8084/products/1
```

### Modèle `Product`

```json
{
  "id": 1,
  "name": "Clavier mécanique",
  "price": 79.90,
  "quantity": 25
}
```

## Docker

### Build et exécution en local

```bash
docker build -t test-web .
docker run -p 8084:8084 test-web
```

L'API est alors disponible sur <http://localhost:8084/products>.

Le [`Dockerfile`](Dockerfile) utilise un build **multi-stage** : une première
étape (JDK 21) compile le jar avec `./gradlew bootJar`, puis l'image finale ne
contient que le JRE et le jar, pour rester légère.

### Intégration continue (GitHub Actions)

Le workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) s'exécute sur
chaque `push` et `pull_request` vers `main` :

1. **Build & test** : `./gradlew build` (compilation + tests) sur JDK 21.
2. **Build & push de l'image** : si les tests passent, l'image est construite et
   publiée sur **GitHub Container Registry** (`ghcr.io/<owner>/test-web`).
   La poussée n'a lieu que sur `push` vers `main` (les pull requests valident
   uniquement que le build Docker fonctionne).

Aucun secret à configurer : l'authentification utilise le `GITHUB_TOKEN`
automatique. Tags générés : `latest`, le nom de la branche et le SHA du commit.

```bash
# Récupérer l'image publiée
docker pull ghcr.io/<owner>/test-web:latest
```

## Tests

```bash
# Tous les tests
./gradlew test

# Une classe de test précise
./gradlew test --tests "com.sfeir.testweb.TestWebApplicationTests"
```

## Structure du projet

```
src/main/java/com/sfeir/testweb/
├── TestWebApplication.java      # Point d'entrée Spring Boot
├── entities/Product.java        # Entité JPA
├── repository/ProductRepository.java  # Repository Spring Data JPA
└── web/ProductController.java   # Contrôleur REST
src/main/resources/
├── application.yaml             # Configuration (port, datasource, H2)
└── data.sql                     # Données initiales
```
