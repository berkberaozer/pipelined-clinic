# Use a minimal JRE base image (not a full JDK — we already compiled)
FROM eclipse-temurin:21-jre-jammy

# Create a non-root user inside the container
RUN groupadd --system appgroup && \
    useradd --system --gid appgroup --no-create-home appuser

WORKDIR /app

# Copy the compiled JAR from the Maven build
COPY target/*.jar app.jar

# Switch to non-root user
USER appuser

# Spring Boot default port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
