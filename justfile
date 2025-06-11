default:
    @just --list

binary_name := "myapp"
binary_path := "./cmd/" + binary_name

# Create a new Go project from this template
new-project name="":
    #!/usr/bin/env bash
    set -euo pipefail
    
    # Get project name
    if [ -z "{{name}}" ]; then
        read -p "Enter the new project name: " PROJECT_NAME
    else
        PROJECT_NAME="{{name}}"
    fi
    
    # Validate project name
    if [ -z "$PROJECT_NAME" ]; then
        echo "Error: Project name cannot be empty"
        exit 1
    fi
    
    # Get GitHub owner (personal or organization)
    echo "Where should this repository be created?"
    echo "1) Personal (bobflorian)"
    echo "2) Organization (Planstone)"
    read -p "Select (1 or 2): " OWNER_CHOICE
    
    case $OWNER_CHOICE in
        1)
            GITHUB_OWNER="bobflorian"
            ;;
        2)
            GITHUB_OWNER="Planstone"
            ;;
        *)
            echo "Error: Invalid choice"
            exit 1
            ;;
    esac
    
    # Set source and target directories
    SOURCE_DIR="$(pwd)"
    TARGET_DIR="../$PROJECT_NAME"
    
    # Check if target directory already exists
    if [ -d "$TARGET_DIR" ]; then
        echo "Error: Directory $TARGET_DIR already exists"
        exit 1
    fi
    
    echo "Creating new Go project: $PROJECT_NAME"
    echo "GitHub: $GITHUB_OWNER/$PROJECT_NAME"
    echo "Location: $TARGET_DIR"
    echo ""
    
    # Create target directory
    mkdir -p "$TARGET_DIR"
    
    # Copy all files except .git and other unwanted files
    echo "Copying template files..."
    rsync -av \
        --exclude='.git/' \
        --exclude='.git' \
        --exclude='.gitignore' \
        --exclude='coverage.out' \
        --exclude='coverage.html' \
        --exclude='bin/' \
        --exclude='*.exe' \
        --exclude='*.test' \
        --exclude='*.out' \
        "$SOURCE_DIR/" "$TARGET_DIR/"
    
    # Change to target directory
    cd "$TARGET_DIR"
    
    # Update go.mod with new project name
    echo "Updating go.mod..."
    if [ -f "go.mod" ]; then
        sed -i.bak "s|module .*|module github.com/$GITHUB_OWNER/$PROJECT_NAME|" go.mod
        rm go.mod.bak
    fi
    
    # Initialize git repository
    echo "Initializing git repository..."
    git init
    
    # Create initial .gitignore if it doesn't exist
    if [ ! -f ".gitignore" ]; then
        cat > .gitignore << 'EOF'
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with `go test -c`
*.test

# Output of the go coverage tool
*.out
coverage.html
coverage.out

# Dependency directories
vendor/

# Go workspace file
go.work

# IDE specific files
.idea/
.vscode/
*.swp
*.swo
*~

# OS specific files
.DS_Store
Thumbs.db

# Project specific
bin/
dist/
*.log
.env
.env.local
EOF
    fi
    
    # Add all files to git
    git add .
    git commit -m "Initial commit from Go template"
    
    # Create GitHub repository
    echo ""
    echo "Creating GitHub repository..."
    gh repo create "$GITHUB_OWNER/$PROJECT_NAME" --private --source=. --remote=origin --push
    
    echo ""
    echo "✅ Successfully created new project: $PROJECT_NAME"
    echo "📁 Location: $TARGET_DIR"
    echo "🔗 GitHub: https://github.com/$GITHUB_OWNER/$PROJECT_NAME"
    echo ""
    echo "Next steps:"
    echo "  cd $TARGET_DIR"
    echo "  go mod tidy"
    echo "  go test ./..."

# Create a new project interactively (alias for new-project)
new: new-project

# Show what files would be copied to a new project
dry-run name="":
    #!/usr/bin/env bash
    set -euo pipefail
    
    # Get project name
    if [ -z "{{name}}" ]; then
        read -p "Enter the new project name: " PROJECT_NAME
    else
        PROJECT_NAME="{{name}}"
    fi
    
    if [ -z "$PROJECT_NAME" ]; then
        echo "Error: Project name cannot be empty"
        exit 1
    fi
    
    SOURCE_DIR="$(pwd)"
    TARGET_DIR="../$PROJECT_NAME"
    
    echo "Would create: $TARGET_DIR"
    echo ""
    echo "Files that would be copied:"
    rsync -av --dry-run \
        --exclude='.git/' \
        --exclude='.git' \
        --exclude='.gitignore' \
        --exclude='coverage.out' \
        --exclude='coverage.html' \
        --exclude='bin/' \
        --exclude='*.exe' \
        --exclude='*.test' \
        --exclude='*.out' \
        "$SOURCE_DIR/" "$TARGET_DIR/" | grep -v "/$" | tail -n +2 | head -n -3

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
