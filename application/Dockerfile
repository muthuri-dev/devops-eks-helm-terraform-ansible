FROM golang:1.25-alpine

WORKDIR /app

# Copy everything first
COPY . .

# Initialize and build
RUN go mod tidy && \
    go mod download && \
    CGO_ENABLED=0 GOOS=linux go build -o main .

EXPOSE 8080

CMD ["./main"]