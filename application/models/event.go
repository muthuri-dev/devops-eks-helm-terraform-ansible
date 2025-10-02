package models

import (
	"time"

	"gorm.io/gorm"
)

// Event represents an event in the system
type Event struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	Title       string    `json:"title" gorm:"not null"`
	Description string    `json:"description" gorm:"type:text;not null"`
	Location    string    `json:"location" gorm:"not null"`
	EventDate   time.Time `json:"event_date" gorm:"not null;index"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// CreateEventRequest represents the request body for creating an event
type CreateEventRequest struct {
	Title       string `json:"title" validate:"required"`
	Description string `json:"description" validate:"required"`
	Location    string `json:"location" validate:"required"`
	EventDate   string `json:"event_date" validate:"required"`
}

// UpdateEventRequest represents the request body for updating an event
type UpdateEventRequest struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	Location    string `json:"location"`
	EventDate   string `json:"event_date"`
}