# Go development justfile
# Run 'just' to see available commands

# Default recipe - show available commands
default:
    @just --list

# Go parameters
binary_name := "myapp"
binary_path := "./cmd/" + binary_name
version := env_var_or_default("VERSION", "1.0.0")
build_time := `date -u '+%Y-%m-%d_%H:%M:%S'`
commit := `git rev-parse --short HEAD 2>/dev/null || echo "unknown"`
ldflags := "-X main.Version=" + version + " -X main.BuildTime=" + build_time + " -X main.Commit=" + commit

# Build for current platform
build:
    go build -ldflags "{{ldflags}}" -o bin/{{binary_name}} -v {{binary_path}}

# Test all packages
test:
    go test -v ./...

# Test with coverage
test-coverage:
    go test -v -race -coverprofile=coverage.out ./...
    go tool cover -html=coverage.out -o coverage.html

# Clean build artifacts
clean:
    go clean
    rm -rf bin/ tmp/ coverage.out coverage.html

# Run the application
run: build
    ./bin/{{binary_name}}

# Run with hot reload using air
dev:
    air -c .air.toml

# Format code
fmt:
    go fmt ./...
    gofumpt -l -w .

# Lint code
lint:
    golangci-lint run ./...

# Run all checks (format, lint, test)
check: fmt lint test

# Update dependencies
update:
    go get -u ./...
    go mod tidy

# Vendor dependencies
vendor:
    go mod vendor

# Cross compilation for Linux AMD64
build-linux-amd64:
    GOOS=linux GOARCH=amd64 go build -ldflags "{{ldflags}}" -o bin/{{binary_name}}-linux-amd64 -v {{binary_path}}

# Cross compilation for Linux ARM64
build-linux-arm64:
    GOOS=linux GOARCH=arm64 go build -ldflags "{{ldflags}}" -o bin/{{binary_name}}-linux-arm64 -v {{binary_path}}

# Cross compilation for macOS AMD64
build-darwin-amd64:
    GOOS=darwin GOARCH=amd64 go build -ldflags "{{ldflags}}" -o bin/{{binary_name}}-darwin-amd64 -v {{binary_path}}

# Cross compilation for macOS ARM64 (Apple Silicon)
build-darwin-arm64:
    GOOS=darwin GOARCH=arm64 go build -ldflags "{{ldflags}}" -o bin/{{binary_name}}-darwin-arm64 -v {{binary_path}}

# Cross compilation for Windows AMD64
build-windows-amd64:
    GOOS=windows GOARCH=amd64 go build -ldflags "{{ldflags}}" -o bin/{{binary_name}}-windows-amd64.exe -v {{binary_path}}

# Cross compilation for Windows ARM64
build-windows-arm64:
    GOOS=windows GOARCH=arm64 go build -ldflags "{{ldflags}}" -o bin/{{binary_name}}-windows-arm64.exe -v {{binary_path}}

# Build for all platforms
build-all: build-linux-amd64 build-linux-arm64 build-darwin-amd64 build-darwin-arm64 build-windows-amd64 build-windows-arm64

# Docker: Build the development container
docker-build:
    docker compose build

# Docker: Start the development container
docker-up:
    docker compose up -d

# Docker: Stop the development container
docker-down:
    docker compose down

# Docker: Enter the development container shell
docker-shell:
    docker compose exec go-dev /bin/bash

# Docker: View container logs
docker-logs:
    docker compose logs -f go-dev

# Docker: Rebuild and restart container
docker-restart: docker-down docker-build docker-up

# Generate mocks (if using mockgen)
mocks:
    go generate ./...

# Run benchmarks
bench pattern="":
    go test -bench={{pattern}} -benchmem ./...

# Security scan with gosec
security:
    gosec -fmt=junit-xml -out=gosec-report.xml ./... || true

# Check for vulnerabilities
vuln:
    go run golang.org/x/vuln/cmd/govulncheck@latest ./...

# Initialize a new Go module
init module_name:
    go mod init {{module_name}}

# Create a new migration (example for common pattern)
new-migration name:
    @echo "Creating migration: {{name}}"
    @mkdir -p migrations
    @touch migrations/$(date +%Y%m%d%H%M%S)_{{name}}.up.sql
    @touch migrations/$(date +%Y%m%d%H%M%S)_{{name}}.down.sql

# Install development tools
install-tools:
    go install golang.org/x/tools/gopls@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    go install honnef.co/go/tools/cmd/staticcheck@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    go install github.com/air-verse/air@latest
    go install mvdan.cc/gofumpt@latest
    go install github.com/securego/gosec/v2/cmd/gosec@latest
    go install golang.org/x/vuln/cmd/govulncheck@latest

# Show Go environment info
env:
    go env

# Quick build and test
quick: fmt build test

# Full CI pipeline
ci: clean check build-all