package config

import (
	"net/url"
	"os"
	"strings"
)

// Config holds the application configuration
type Config struct {
	Port       string
	DatabaseURL string
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	DBSSLMode  string
}

// LoadConfig loads configuration from environment variables
func LoadConfig() *Config {
	config := &Config{
		Port:        getEnv("PORT", "8080"),
		DatabaseURL: getEnv("DATABASE_URL", ""),
		DBHost:      getEnv("DB_HOST", "localhost"),
		DBPort:      getEnv("DB_PORT", "5432"),
		DBUser:      getEnv("DB_USER", "postgres"),
		DBPassword:  getEnv("DB_PASSWORD", "password"),
		DBName:      getEnv("DB_NAME", "events_db"),
		DBSSLMode:   getEnv("DB_SSL_MODE", "disable"),
	}

	// If DATABASE_URL is provided, parse it and override individual settings
	if config.DatabaseURL != "" {
		if parsed, err := url.Parse(config.DatabaseURL); err == nil {
			config.DBHost = parsed.Hostname()
			config.DBPort = parsed.Port()
			if config.DBPort == "" {
				config.DBPort = "5432"
			}
			config.DBUser = parsed.User.Username()
			if password, ok := parsed.User.Password(); ok {
				config.DBPassword = password
			}
			config.DBName = strings.TrimPrefix(parsed.Path, "/")
			if sslmode := parsed.Query().Get("sslmode"); sslmode != "" {
				config.DBSSLMode = sslmode
			}
		}
	}

	return config
}

// getEnv gets an environment variable or returns a default value
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}