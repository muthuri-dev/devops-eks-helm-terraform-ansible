FROM golang:1.25-alpine AS builder

ARG VERSION=dev
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Set Go environment and build
ENV GO111MODULE=on
ENV GOFLAGS=-mod=mod
RUN go mod tidy && \
    CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-w -s -X main.version=${VERSION}" \
    -o main .

# Start a new stage from scratch
FROM alpine:3.18

RUN apk --no-cache add ca-certificates tzdata curl

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy the pre-built binary file from the previous stage
COPY --from=builder --chown=appuser:appuser /app/main .

USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Expose port 8080
EXPOSE 8080

# Command to run the executable
CMD ["./main"]