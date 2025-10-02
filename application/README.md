# Events API

A simple RESTful API for managing events built with Go, Gin, and GORM.

## Features

- Create, read, update, and delete events
- Get upcoming events
- PostgreSQL database with GORM
- RESTful API endpoints
- Docker support
- Simple and clean architecture

## API Endpoints

### Health Check

- `GET /health` - Check if the service is running

### Events

- `POST /api/v1/events` - Create a new event
- `GET /api/v1/events` - Get all events
- `GET /api/v1/events/upcoming` - Get upcoming events
- `GET /api/v1/events/:id` - Get event by ID
- `PUT /api/v1/events/:id` - Update event by ID
- `DELETE /api/v1/events/:id` - Delete event by ID

## Event Model

```json
{
  "id": 1,
  "title": "Conference 2024",
  "description": "Annual tech conference",
  "location": "San Francisco, CA",
  "event_date": "2024-12-01T10:00:00Z",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

## Setup and Running

### Prerequisites

- Go 1.21+
- PostgreSQL database (running separately)

### Database Connection

You can connect to your existing PostgreSQL database using either:

**Option 1: Individual environment variables**

```bash
DB_HOST=your_host
DB_PORT=5432
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=your_database
DB_SSL_MODE=disable
```

**Option 2: DATABASE_URL (takes precedence if set)**

```bash
DATABASE_URL=postgresql://username:password@hostname:port/database_name?sslmode=disable
```

### Environment Variables

Copy `.env.example` to `.env` and update with your PostgreSQL connection details:

```bash
cp .env.example .env
```

### Running Locally

1. Install dependencies:

```bash
go mod tidy
```

2. Update your `.env` file with your PostgreSQL connection details

3. Run the application:

```bash
go run main.go
```

The server will start on `http://localhost:8080`

### Using Docker

```bash
# Build
docker build -t events-api .

# Run
docker run -p 8080:8080 --env-file .env events-api
```

## Example Usage

### Create an Event

```bash
curl -X POST http://localhost:8080/api/v1/events \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Tech Conference 2024",
    "description": "Annual technology conference",
    "location": "San Francisco, CA",
    "event_date": "2024-12-01 10:00:00"
  }'
```

### Get All Events

```bash
curl http://localhost:8080/api/v1/events
```

### Get Upcoming Events

```bash
curl http://localhost:8080/api/v1/events/upcoming
```

### Update an Event

```bash
curl -X PUT http://localhost:8080/api/v1/events/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Conference Title"
  }'
```

### Delete an Event

```bash
curl -X DELETE http://localhost:8080/api/v1/events/1
```

## Architecture

The application follows a clean architecture pattern:

```
application/
├── main.go                 # Application entry point
├── config/                 # Configuration management
│   └── config.go
├── database/               # Database connection and migrations
│   └── database.go
├── models/                 # Data models
│   └── event.go
├── repository/             # Data access layer
│   └── event_repository.go
├── service/                # Business logic layer
│   └── event_service.go
├── handlers/               # HTTP handlers
│   └── event_handler.go
├── routes/                 # Route definitions
│   └── routes.go
├── Dockerfile
├── .env.example
└── README.md
```

## Dependencies

- [Gin](https://github.com/gin-gonic/gin) - HTTP web framework
- [GORM](https://gorm.io/) - ORM for Go
- [PostgreSQL Driver](https://github.com/lib/pq) - PostgreSQL driver
- [godotenv](https://github.com/joho/godotenv) - Environment variable loader
