FROM golang:1.21-alpine

WORKDIR /app

COPY . .

RUN go mod download && go build -o main .

EXPOSE 8080

CMD ["./main"]