#!/bin/bash

# Exit on error
set -e

# Configuration - Modify these variables as needed
PROJECT_NAME="my-spring-app"
GROUP_ID="com.example"
ARTIFACT_ID="spring-demo"
DESCRIPTION="Spring Boot Application"
# Using Spring Boot 3.4.1 (current supported version)
JAVA_VERSION="17"
SPRING_BOOT_VERSION="3.4.1"
PACKAGING="jar"
# Core dependencies - compatible with Spring Boot 3.4.1
DEPENDENCIES="web,data-jpa,mysql,lombok"
# Cleanup function
cleanup() {
    echo "Cleaning up..."
    rm -f project.zip
    exit 1
}

# Set up trap for cleanup on script interruption
trap cleanup INT TERM

# Check for required commands
for cmd in curl unzip; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: Required command '$cmd' not found. Please install it first."
        exit 1
    fi
done

# Check if project directory already exists
if [ -d "$PROJECT_NAME" ]; then
    echo "Error: Directory '$PROJECT_NAME' already exists. Please remove it or use a different project name."
    exit 1
fi

# Print configuration
echo "Creating Spring Boot project with following configuration:"
echo "Project Name: $PROJECT_NAME"
echo "Group ID: $GROUP_ID"
echo "Artifact ID: $ARTIFACT_ID"
echo "Java Version: $JAVA_VERSION"
echo "Spring Boot Version: $SPRING_BOOT_VERSION"
echo "Dependencies: $DEPENDENCIES"
echo

# Create project using Spring Initializr
echo "Generating Spring Boot project from start.spring.io..."
echo "This may take a few moments..."
HTTP_RESPONSE=$(curl -s -w "%{http_code}" "https://start.spring.io/starter.zip" \
    --progress-bar \
    -d type="maven-project" \
    -d language="java" \
    -d bootVersion="${SPRING_BOOT_VERSION}" \
    -d baseDir="${PROJECT_NAME}" \
    -d groupId="${GROUP_ID}" \
    -d artifactId="${ARTIFACT_ID}" \
    -d name="${PROJECT_NAME}" \
    -d description="${DESCRIPTION}" \
    -d packageName="${GROUP_ID}" \
    -d packaging="${PACKAGING}" \
    -d javaVersion="${JAVA_VERSION}" \
    -d dependencies="${DEPENDENCIES}" \
    --progress-bar \
    -o project.zip)

if [ $? -ne 0 ]; then
    echo "Error: Failed to download project from Spring Initializr"
    cleanup
fi

# Check HTTP response
if [ "$HTTP_RESPONSE" -ne 200 ]; then
    echo "Error: Server returned HTTP code $HTTP_RESPONSE"
    cleanup
fi

# Verify zip file
if ! unzip -t project.zip > /dev/null 2>&1; then
    echo "Error: Downloaded file is not a valid ZIP archive"
    cleanup
fi

# Create project directory
echo "Extracting project..."
if ! unzip -q project.zip; then
    echo "Error: Failed to extract project"
    cleanup
fi

# Clean up zip file
rm -f project.zip

echo
echo "Project created successfully!"
echo
echo "To run the project:"
echo "  cd $PROJECT_NAME"
echo "  ./mvnw spring-boot:run"
