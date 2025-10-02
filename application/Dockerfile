FROM golang:1.25-alpine AS builder

ARG VERSION=dev
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Set Go environment variables for module mode
ENV GO111MODULE=on
ENV GOFLAGS=-mod=readonly

# Build the application with version information
RUN CGO_ENABLED=0 GOOS=linux go build \
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

# Expose port 8080
EXPOSE 8080

# Command to run the executable
CMD ["./main"]