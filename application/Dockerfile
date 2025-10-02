FROM golang:1.21-alpine

WORKDIR /app

# Copy everything
COPY . .

# Build the application
RUN go build -o main .

EXPOSE 8080

CMD ["./main"]