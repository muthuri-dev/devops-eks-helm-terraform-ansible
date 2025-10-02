FROM golang:1.25-alpine

WORKDIR /app

# Copy everything
COPY . .

# Build
RUN go mod tidy && go build -o main .

# Expose port
EXPOSE 8080

# Run
CMD ["./main"]