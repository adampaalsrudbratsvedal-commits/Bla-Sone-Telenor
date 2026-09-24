FROM maven:3.9-eclipse-temurin-21

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Copy pom.xml first for better Docker layer caching
COPY pom.xml .

# Download dependencies (this layer will be cached unless pom.xml changes)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Expose port and remote debugging port
EXPOSE 8080 5005

# Startup script that runs the app and restarts it when files in src change.
# sed strips Windows line endings in case Git checked the script out with CRLF.
COPY dev-watch.sh /usr/local/bin/watch-and-run.sh
RUN sed -i 's/\r$//' /usr/local/bin/watch-and-run.sh && chmod +x /usr/local/bin/watch-and-run.sh

CMD ["/usr/local/bin/watch-and-run.sh"]
