#!/bin/bash

# Run the Spring Boot creator script first
echo "Creating Spring Boot project..."
./SpringBootProjectCreator.sh

# Wait for the project to be created
if [ ! -d "my-spring-app" ]; then
    echo "Error: Spring Boot project creation failed"
    exit 1
fi

echo "Creating Dockerfile..."
cat > my-spring-app/Dockerfile << 'EOL'
# Build stage
FROM maven:3.8.4-openjdk-17-slim AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Run stage
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOL

echo "Creating docker-compose.yml..."
cat > my-spring-app/docker-compose.yml << 'EOL'
version: '3.8'
services:
app:
    build: .
    ports:
    - "8080:8080"
    environment:
    - SPRING_PROFILES_ACTIVE=docker
    restart: unless-stopped
EOL

echo "Adding README with Docker instructions..."
cat > my-spring-app/README.md << 'EOL'
# Spring Boot Docker Application

## Building and Running with Docker

### Build the Docker image
```bash
docker build -t spring-boot-app .
```

### Run with Docker
```bash
docker run -p 8080:8080 spring-boot-app
```

### Run with Docker Compose
```bash
docker-compose up
```

### Stop Docker Compose
```bash
docker-compose down
```

The application will be available at http://localhost:8080
EOL

echo "Setup complete! Your Spring Boot project is ready with Docker support."
echo "Navigate to the project directory:"
echo "  cd my-spring-app"
echo "Then you can build and run with Docker using the instructions in README.md"

