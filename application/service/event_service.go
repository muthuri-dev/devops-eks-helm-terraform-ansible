package service

import (
	"fmt"
	"strconv"
	"time"

	"github.com/muthuri-dev/devops-eks-helm-terraform-ansible/application/models"
	"github.com/muthuri-dev/devops-eks-helm-terraform-ansible/application/repository"
	"gorm.io/gorm"
)

// EventService handles business logic for events
type EventService struct {
	repo *repository.EventRepository
}

// NewEventService creates a new event service
func NewEventService() *EventService {
	return &EventService{
		repo: repository.NewEventRepository(),
	}
}

// CreateEvent creates a new event
func (s *EventService) CreateEvent(req *models.CreateEventRequest) (*models.Event, error) {
	// Parse the event date
	eventDate, err := s.parseEventDate(req.EventDate)
	if err != nil {
		return nil, err
	}

	// Validate that the event date is in the future
	if eventDate.Before(time.Now()) {
		return nil, fmt.Errorf("event date must be in the future")
	}

	event := &models.Event{
		Title:       req.Title,
		Description: req.Description,
		Location:    req.Location,
		EventDate:   eventDate,
	}

	err = s.repo.CreateEvent(event)
	if err != nil {
		return nil, fmt.Errorf("failed to create event: %w", err)
	}

	return event, nil
}

// GetEventByID retrieves an event by its ID
func (s *EventService) GetEventByID(idStr string) (*models.Event, error) {
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		return nil, fmt.Errorf("invalid event ID")
	}

	event, err := s.repo.GetEventByID(uint(id))
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, fmt.Errorf("event not found")
		}
		return nil, err
	}

	return event, nil
}

// GetAllEvents retrieves all events
func (s *EventService) GetAllEvents() ([]*models.Event, error) {
	events, err := s.repo.GetAllEvents()
	if err != nil {
		return nil, fmt.Errorf("failed to get events: %w", err)
	}

	return events, nil
}

// GetUpcomingEvents retrieves upcoming events
func (s *EventService) GetUpcomingEvents() ([]*models.Event, error) {
	events, err := s.repo.GetUpcomingEvents()
	if err != nil {
		return nil, fmt.Errorf("failed to get upcoming events: %w", err)
	}

	return events, nil
}

// UpdateEvent updates an existing event
func (s *EventService) UpdateEvent(idStr string, req *models.UpdateEventRequest) (*models.Event, error) {
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		return nil, fmt.Errorf("invalid event ID")
	}

	// Get the existing event
	existingEvent, err := s.repo.GetEventByID(uint(id))
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, fmt.Errorf("event not found")
		}
		return nil, err
	}

	// Update fields if provided
	if req.Title != "" {
		existingEvent.Title = req.Title
	}
	if req.Description != "" {
		existingEvent.Description = req.Description
	}
	if req.Location != "" {
		existingEvent.Location = req.Location
	}
	if req.EventDate != "" {
		eventDate, err := s.parseEventDate(req.EventDate)
		if err != nil {
			return nil, err
		}
		existingEvent.EventDate = eventDate
	}

	err = s.repo.UpdateEvent(existingEvent)
	if err != nil {
		return nil, fmt.Errorf("failed to update event: %w", err)
	}

	return existingEvent, nil
}

// DeleteEvent deletes an event by its ID
func (s *EventService) DeleteEvent(idStr string) error {
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		return fmt.Errorf("invalid event ID")
	}

	err = s.repo.DeleteEvent(uint(id))
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return fmt.Errorf("event not found")
		}
		return fmt.Errorf("failed to delete event: %w", err)
	}

	return nil
}

// parseEventDate parses event date from string with multiple format support
func (s *EventService) parseEventDate(dateStr string) (time.Time, error) {
	// Try different date formats
	formats := []string{
		"2006-01-02T15:04:05Z",
		"2006-01-02T15:04:05",
		"2006-01-02 15:04:05",
		"2006-01-02",
	}

	for _, format := range formats {
		if eventDate, err := time.Parse(format, dateStr); err == nil {
			return eventDate, nil
		}
	}

	return time.Time{}, fmt.Errorf("invalid event date format. Use YYYY-MM-DD HH:MM:SS or YYYY-MM-DD")
}