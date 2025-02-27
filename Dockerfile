FROM golang:1.24 AS builder

WORKDIR /app

# Copy the Go module files and download dependencies
COPY go.mod go.sum  /app/
RUN go mod download

# Copy the rest of the application source code
COPY ./cmd/api /app/cmd/api
COPY ./internal /app/internal
COPY ./cmd/api/.env.development ./cmd/api/.env.production /app/

# Build the Go application
RUN env GOOS=linux GOARCH=amd64 go build -o main cmd/api/main.go

# Create a minimal runtime image
FROM amazonlinux:2023
WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/.env.development .
COPY --from=builder /app/.env.production .

# Expose port 8080 for incoming requests
EXPOSE 8080

# Command to run the application
CMD ["./main"]
