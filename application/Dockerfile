FROM golang:1.25-alpine

# Set environment variables for Go modules
ENV GO111MODULE=on
ENV GOPATH=""
ENV GOPROXY=https://proxy.golang.org,direct
ENV GOSUMDB=sum.golang.org

WORKDIR /app

# Copy go mod files first
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Debug: Show what files we have and module info
RUN ls -la && \
    go env GOMOD && \
    go env GO111MODULE && \
    go mod graph | head -5

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

EXPOSE 8080

CMD ["./main"]