.PHONY: start stop restart status install build dev clean help firewall-open firewall-close

# Configuration
PORT ?= 4567
PID_FILE = .polly.pid
SCRIPTS_DIR = scripts

help:
	@echo "Polly - Local Network Polling App"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install        Install all dependencies (Ruby + Node)"
	@echo "  build          Build the frontend for production"
	@echo "  start          Build & start server in background"
	@echo "  stop           Stop the server"
	@echo "  restart        Restart the server"
	@echo "  status         Check if server is running"
	@echo "  dev            Start frontend dev server (hot reload)"
	@echo "  logs           Tail server logs"
	@echo "  clean          Remove build artifacts"
	@echo ""
	@echo "Firewall (requires sudo):"
	@echo "  firewall-open  Open port for LAN access"
	@echo "  firewall-close Close port"
	@echo ""
	@echo "Options:"
	@echo "  PORT=4567      Set server port (default: 4567)"

install:
	@echo "Installing Ruby dependencies..."
	cd server && bundle install
	@echo "Installing Node dependencies..."
	cd frontend && npm install
	@echo "Done!"

build:
	@echo "Building frontend..."
	cd frontend && npm run build
	@echo "Build complete!"

start: build
	@if [ -f $(PID_FILE) ] && kill -0 $$(cat $(PID_FILE)) 2>/dev/null; then \
		echo "Server already running (PID: $$(cat $(PID_FILE)))"; \
	else \
		echo "Starting server on port $(PORT)..."; \
		cd server && nohup bundle exec puma -C puma.rb config.ru --pidfile ../$(PID_FILE) > polly.log 2>&1 & \
		sleep 2; \
		if [ -f $(PID_FILE) ]; then \
			echo "Server started (PID: $$(cat $(PID_FILE)))"; \
			echo "  Participant view: http://localhost:$(PORT)"; \
			echo "  Admin dashboard:  http://localhost:$(PORT)/admin"; \
		else \
			echo "Failed to start server. Check server/polly.log"; \
		fi \
	fi

stop:
	@if [ -f $(PID_FILE) ]; then \
		echo "Stopping server (PID: $$(cat $(PID_FILE)))..."; \
		kill $$(cat $(PID_FILE)) 2>/dev/null || true; \
		rm -f $(PID_FILE); \
		echo "Server stopped"; \
	else \
		echo "No PID file found, killing any puma processes on port $(PORT)..."; \
		pkill -f "puma.*$(PORT)" 2>/dev/null || true; \
		echo "Done"; \
	fi

restart: stop start

status:
	@if [ -f $(PID_FILE) ] && kill -0 $$(cat $(PID_FILE)) 2>/dev/null; then \
		echo "Server is running (PID: $$(cat $(PID_FILE)))"; \
		curl -s http://localhost:$(PORT)/api/info | python3 -m json.tool 2>/dev/null || echo "API not responding"; \
	else \
		echo "Server is not running"; \
	fi

dev:
	@echo "Starting frontend dev server..."
	@echo "Make sure the backend is running (make start)"
	cd frontend && npm run dev

logs:
	@if [ -f server/polly.log ]; then \
		tail -f server/polly.log; \
	else \
		echo "No log file found"; \
	fi

clean:
	rm -rf frontend/dist
	rm -rf frontend/node_modules
	rm -rf server/vendor
	rm -f $(PID_FILE)
	rm -f server/polly.log
	@echo "Cleaned!"

# Firewall management (macOS specific)
firewall-open:
	@$(SCRIPTS_DIR)/open_port.sh $(PORT)

firewall-close:
	@$(SCRIPTS_DIR)/close_port.sh $(PORT)
