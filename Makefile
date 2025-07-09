BACKEND_DIR := surfsense_backend
WEB_DIR := surfsense_web
BROWSER_EXTENSION_DIR := surfsense_browser_extension

# Try pip3, fallback to pip
PIP := $(shell command -v pip3 || command -v pip)
ARCH := $(shell uname -m)

.PHONY: \
default \
create-backend-env create-web-env ensure-uv ensure-pnpm approve-pnpm-builds \
setup setup-backend setup-frontend \
dev dev-backend dev-frontend \
install-pgvector ensure-postgres ensure-postgres-user ensure-db \
db-init db-migrate db-reset \
create-browser-extension-env setup-browser-extension build-browser-extension

# Default
default:
	make db-init & \
	make db-migrate & \
	make setup

create-backend-env:
	cd $(BACKEND_DIR) && \
	cp .env.example .env

create-web-env:
	cd $(WEB_DIR) && \
	cp .env.example .env

ensure-uv:
	@command -v uv >/dev/null 2>&1 && { \
		echo "✅ uv already installed."; \
	} || { \
		echo "⚠️  uv not found. Attempting to install..."; \
		if command -v pipx >/dev/null 2>&1; then \
			echo "📦 Installing uv using pipx..."; \
			pipx install uv; \
		elif command -v pip3 >/dev/null 2>&1; then \
			echo "📦 Installing uv using pip3 --user (fallback)..."; \
			pip3 install --user uv; \
			echo "⚠️ Make sure ~/.local/bin is in your PATH."; \
		elif command -v pip >/dev/null 2>&1; then \
			echo "📦 Installing uv using pip --user (fallback)..."; \
			pip install --user uv; \
			echo "⚠️ Make sure ~/.local/bin is in your PATH."; \
		else \
			echo "❌ Could not find pipx or pip. Please install uv manually."; \
			exit 1; \
		fi; \
	}

ensure-pnpm:
	@command -v pnpm >/dev/null 2>&1 && { \
		echo "✅ pnpm is already installed."; \
	} || { \
		echo "📦 Installing pnpm globally with npm..."; \
		npm install -g pnpm || { \
			echo "❌ Failed to install pnpm. Please install it manually."; \
			exit 1; \
		}; \
	}

approve-pnpm-builds:
	@pnpm config set enable-pre-post-scripts true

# Environment Setup
# setup - Install all dependencies across components
setup:
	make setup-backend & \
	make setup-frontend

# setup-backend - Set up Python environment and dependencies
setup-backend: ensure-uv create-backend-env
	@command -v uv >/dev/null 2>&1 || { echo "❌ uv still not found. Aborting."; exit 1; }
	cd $(BACKEND_DIR) && \
	uv sync

# setup-frontend - Set up Next.js dependencies
setup-frontend: create-web-env ensure-pnpm
	cd $(WEB_DIR) && \
	pnpm install

# Development
# dev - Start all components in development mode
dev:
	make dev-backend & \
	make dev-frontend & \
	wait

# dev-backend - Start backend server with hot reloading
dev-backend:
	cd $(BACKEND_DIR) && \
	uv run main.py --reload

# dev-frontend - Start frontend server
dev-frontend: ensure-pnpm
	pnpm run dev

# dev-extension - Build extension in dev mode
# Browser extension doesn't have a dev mode

# Testing & Quality
# @TODO test - Run all tests
# @TODO lint - Run linting across all components
# @TODO format - Format code according to project standards


# Build & Deployment


# @TODO build - Build all components

# @TODO docker - Build Docker images

# @TODO package-extension - Package browser extension for distribution


# Database Helpers
# install-pgvector - Compile and install extension
# @TODO: Add setting pg_config?
install-pgvector:
	@if [ ! -d /tmp/pgvector ]; then \
		echo "Cloning pgvector..."; \
		git clone --branch v0.8.0 https://github.com/pgvector/pgvector.git /tmp/pgvector; \
	fi && \
	cd /tmp/pgvector && \
	[ -f pgvector.so ] || make PG_CONFIG=$(PG_CONFIG) && \
	echo "Using pg_config at: $(PG_CONFIG)" && \
	sudo make PG_CONFIG=$(PG_CONFIG) install

# Checks if Postgres is running by trying to connect to it
ensure-postgres:
	@pg_isready -h localhost >/dev/null 2>&1 || { \
		echo "❌ Postgres is not running."; \
		echo "➡️  Try: brew services start postgresql@17"; \
		exit 1; \
	}
	@echo "✅ Postgres is running."

# Checks if the 'postgres' role exists, creates it if missing
ensure-postgres-user:
	@psql -U postgres -h localhost -d postgres -tc "SELECT 1 FROM pg_roles WHERE rolname='postgres'" | grep -q 1 || { \
		echo "⚠️  Role 'postgres' not found. Creating it..."; \
		createuser -s postgres || { echo "❌ Failed to create role 'postgres'."; exit 1; }; \
	}
	@echo "✅ Role 'postgres' exists."

ensure-db:
	@psql -U postgres -h localhost -tc "SELECT 1 FROM pg_database WHERE datname = 'surfsense'" | grep -q 1 || { \
		echo "📦 Creating database 'surfsense'..."; \
		createdb -U postgres -h localhost surfsense; \
	}
	@echo "✅ Database 'surfsense' exists."

# Database
# db-init - Initialize database and pgvector
db-init: install-pgvector ensure-postgres ensure-postgres-user ensure-db
	@echo "🛠️  Postgres is ready for use."

# db-migrate - Run all migrations
db-migrate:
	cd $(BACKEND_DIR) && \
	alembic upgrade head

# db-reset - Drop, recreate, and migrate the database (for development)
db-reset:
	@read -p "⚠️  This will DESTROY and recreate the 'surfsense' database. Are you sure? (y/N) " confirm && \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		psql -U postgres -h localhost -c "DROP DATABASE IF EXISTS surfsense WITH (FORCE);" && \
		createdb -U postgres -h localhost surfsense && \
		cd $(BACKEND_DIR) && \
		alembic upgrade head && \
		echo "✅ Database reset complete."; \
	else \
		echo "❌ Aborted."; \
	fi

# Browser Extension
# Helpers
create-browser-extension-env:
	cd $(BROWSER_EXTENSION_DIR) && \
	cp .env.example .env

# setup-browser-extension - Set up browser extension dependencies
setup-browser-extension: create-browser-extension-env ensure-pnpm approve-pnpm-builds
	cd $(BROWSER_EXTENSION_DIR) && \
	pnpm install && \
	ARCH=$$(uname -m); \
	if [ "$$ARCH" = "arm64" ]; then \
		echo "🔧 Rebuilding sharp for Apple Silicon..."; \
		pnpm rebuild sharp --unsafe-perm=true; \
	else \
		echo "🔧 Rebuilding sharp for Intel or other arch..."; \
		pnpm rebuild sharp; \
	fi

# build-browser-extension - Build browser extension
TARGET ?= chrome
build-browser-extension: ensure-pnpm approve-pnpm-builds
	@echo "Building browser extension for target: $(TARGET)"
	cd $(BROWSER_EXTENSION_DIR) && \
	pnpm build --target=$(TARGET)

# start-fresh - Clean up and reinitialize everything from scratch (manual setup only, no Docker)
start-fresh:
	@echo "🧹 Cleaning up all previous environments and dependencies..."
	rm -rf $(BACKEND_DIR)/.venv \
		$(WEB_DIR)/node_modules \
		$(BROWSER_EXTENSION_DIR)/node_modules \
		$(BACKEND_DIR)/__pycache__ \
		$(BACKEND_DIR)/.mypy_cache \
		$(BACKEND_DIR)/.pytest_cache \
		$(BACKEND_DIR)/.ruff_cache && \
	find . -name "*.pyc" -delete

	@echo "🧼 Removing .env files..."
	rm -f $(BACKEND_DIR)/.env \
		$(WEB_DIR)/.env \
		$(BROWSER_EXTENSION_DIR)/.env

	@echo "🗃️  Dropping and recreating the database..."
	psql -U postgres -h localhost -c "DROP DATABASE IF EXISTS surfsense WITH (FORCE);"
