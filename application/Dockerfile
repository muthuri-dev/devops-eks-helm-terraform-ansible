FROM golang:1.25-alpine

WORKDIR /app

COPY . .

ENV GO111MODULE=on
RUN go mod tidy && go build -o main .

EXPOSE 8080

CMD ["./main"]