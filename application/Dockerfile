FROM golang:1.25-alpine

WORKDIR /app

COPY . .

RUN go mod tidy && go mod download && go build -o main .

EXPOSE 8080

CMD ["./main"]