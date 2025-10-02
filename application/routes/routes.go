package routes

import (
	"github.io/muthuri-dev/devops-eks-helm-terraform-ansible/application/handlers"

	"github.com/gin-gonic/gin"
)

// SetupRoutes configures all the routes for the application
func SetupRoutes(router *gin.Engine) {
	eventHandler := handlers.NewEventHandler()

	// Health check
	router.GET("/health", eventHandler.HealthCheck)

	// API v1 routes
	v1 := router.Group("/api/v1")
	{
		// Event routes
		events := v1.Group("/events")
		{
			events.POST("/", eventHandler.CreateEvent)
			events.GET("/", eventHandler.GetAllEvents)
			events.GET("/upcoming", eventHandler.GetUpcomingEvents)
			events.GET("/:id", eventHandler.GetEventByID)
			events.PUT("/:id", eventHandler.UpdateEvent)
			events.DELETE("/:id", eventHandler.DeleteEvent)
		}
	}
}