FROM golang:1.25-alpine AS builder

ARG VERSION=dev
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Verify the structure
RUN ls -la && ls -la config/

# Set Go environment and build
ENV GO111MODULE=on
ENV GOFLAGS=-mod=mod
RUN go mod tidy && \
    CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-w -s -X main.version=${VERSION}" \
    -o main .

FROM alpine:3.18
RUN apk --no-cache add ca-certificates tzdata curl
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser
WORKDIR /app
COPY --from=builder --chown=appuser:appuser /app/main .
USER appuser
EXPOSE 8080
CMD ["./main"]