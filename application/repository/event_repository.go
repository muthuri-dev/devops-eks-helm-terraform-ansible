package repository

import (
	"time"

	"application/database"
	"application/models"

	"gorm.io/gorm"
)

// EventRepository handles database operations for events
type EventRepository struct {
	db *gorm.DB
}

// NewEventRepository creates a new event repository
func NewEventRepository() *EventRepository {
	return &EventRepository{
		db: database.DB,
	}
}

// CreateEvent creates a new event in the database
func (r *EventRepository) CreateEvent(event *models.Event) error {
	return r.db.Create(event).Error
}

// GetEventByID retrieves an event by its ID
func (r *EventRepository) GetEventByID(id uint) (*models.Event, error) {
	var event models.Event
	err := r.db.First(&event, id).Error
	if err != nil {
		return nil, err
	}
	return &event, nil
}

// GetAllEvents retrieves all events from the database
func (r *EventRepository) GetAllEvents() ([]*models.Event, error) {
	var events []*models.Event
	err := r.db.Order("event_date ASC").Find(&events).Error
	return events, err
}

// UpdateEvent updates an existing event
func (r *EventRepository) UpdateEvent(event *models.Event) error {
	return r.db.Save(event).Error
}

// DeleteEvent deletes an event by its ID (soft delete)
func (r *EventRepository) DeleteEvent(id uint) error {
	result := r.db.Delete(&models.Event{}, id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

// GetUpcomingEvents retrieves events that are scheduled for the future
func (r *EventRepository) GetUpcomingEvents() ([]*models.Event, error) {
	var events []*models.Event
	err := r.db.Where("event_date > ?", time.Now()).Order("event_date ASC").Find(&events).Error
	return events, err
}