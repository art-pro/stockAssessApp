.PHONY: help install run-backend run-frontend run-all test clean build deploy

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

install: ## Install all dependencies
	@echo "Installing Go dependencies..."
	go mod download
	@echo "Installing frontend dependencies..."
	cd frontend && npm install
	@echo "Done!"

run-backend: ## Run the Go backend server
	@echo "Starting backend server..."
	go run main.go

run-frontend: ## Run the Next.js frontend
	@echo "Starting frontend..."
	cd frontend && npm run dev

run-all: ## Run both backend and frontend (in separate terminals)
	@echo "Please run 'make run-backend' in one terminal and 'make run-frontend' in another"

test: ## Run tests
	@echo "Running backend tests..."
	go test ./...
	@echo "Running frontend tests..."
	cd frontend && npm test

clean: ## Clean build artifacts and dependencies
	@echo "Cleaning..."
	rm -rf data/*.db
	rm -rf frontend/.next
	rm -rf frontend/node_modules
	@echo "Done!"

build: ## Build the application
	@echo "Building backend..."
	go build -o bin/assessapp main.go
	@echo "Building frontend..."
	cd frontend && npm run build
	@echo "Done!"

deploy: ## Deploy to Vercel
	@echo "Deploying backend..."
	vercel --prod
	@echo "Deploying frontend..."
	cd frontend && vercel --prod
	@echo "Done!"

dev: ## Setup and run in development mode
	@echo "Setting up development environment..."
	@if [ ! -f .env ]; then \
		echo "Creating .env from .env.example..."; \
		cp .env.example .env; \
		echo "Please update .env with your configuration"; \
	fi
	@if [ ! -f frontend/.env.local ]; then \
		echo "Creating frontend/.env.local..."; \
		echo "NEXT_PUBLIC_API_URL=http://localhost:8080/api" > frontend/.env.local; \
	fi
	@echo "Setup complete! Run 'make run-backend' and 'make run-frontend' in separate terminals"

