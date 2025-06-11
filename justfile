default:
    @just --list

binary_name := "myapp"
binary_path := "./cmd/" + binary_name

# Build binary
build:
    go build -v -o bin/{{binary_name}} {{binary_path}}

# Run with hot reload
dev:
    air

# Run tests
test:
    go test -v -race ./...

# Run tests with coverage
cover:
    go test -v -race -coverprofile=coverage.txt ./...
    go tool cover -html=coverage.txt -o coverage.html
    @echo "Coverage report: coverage.html"

# Format and lint
check:
    gofumpt -l -w .
    goimports -w .
    golangci-lint run

# Quick format, lint, and test
verify: check test

# Clean build artifacts
clean:
    go clean -cache
    rm -rf bin/ coverage.* *.test

# Update dependencies
deps:
    go get -u ./...
    go mod tidy
    go mod verify


# Run with debugging
debug:
    dlv debug {{binary_path}} --headless --listen=:2345 --api-version=2 --accept-multiclient

build-all: check test audit
    @echo "Building for multiple platforms..."
    GOOS=linux GOARCH=amd64 go build -o bin/{{binary_name}}-linux-amd64 {{binary_path}}
    GOOS=linux GOARCH=arm64 go build -o bin/{{binary_name}}-linux-arm64 {{binary_path}}
    GOOS=darwin GOARCH=amd64 go build -o bin/{{binary_name}}-darwin-amd64 {{binary_path}}
    GOOS=darwin GOARCH=arm64 go build -o bin/{{binary_name}}-darwin-arm64 {{binary_path}}
    GOOS=windows GOARCH=amd64 go build -o bin/{{binary_name}}-windows-amd64.exe {{binary_path}}
    @echo "Build complete!"

# Security audit - requires: go install github.com/sonatype-nexus-community/nancy@latest && go install golang.org/x/vuln/cmd/govulncheck@latest
audit:
    go list -json -deps ./... | nancy sleuth
    govulncheck ./...

# Quick run
run: build
    ./bin/{{binary_name}}
