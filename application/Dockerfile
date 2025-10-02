FROM golang:1.25-alpine

WORKDIR /app

# Copy go mod files first
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Verify module setup and build
RUN go mod verify && \
    go list -m && \
    CGO_ENABLED=0 GOOS=linux go build -v -o main .

EXPOSE 8080

CMD ["./main"]