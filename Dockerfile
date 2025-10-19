# ---- Build stage
FROM gradle:8.10.1-jdk21 AS builder
WORKDIR /app

# Cache dependencies
COPY build.gradle* settings.gradle* gradlew ./
COPY gradle gradle
RUN chmod +x gradlew || true
RUN ./gradlew --version

# Copy sources last to leverage cache
COPY . .
# Build fat jar
RUN ./gradlew clean bootJar -x test

# ---- Run stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
ENV TZ=Asia/Jakarta
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

COPY --from=builder /app/build/libs/*-SNAPSHOT.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
