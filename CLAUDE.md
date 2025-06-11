# CLAUDE.md - Go Development Guide

This document outlines the coding standards, architectural patterns, and best practices for the Go project. Follow these guidelines to maintain consistency across the codebase.

## Project Setup

- Use the provided Dockerfile for consistent development environment
- Follow the existing directory structure when adding new features
- Use go.mod for dependency management

## Build & Test Commands

- Build: `go build`
- Run with hot reload: `arelo -p '**/*.go' -i '**/.*' -i '**/*_test.go' -- go run main.go`
- Run all tests: `go test ./...`
- Run single test: `go test -run '^TestName$' ./path/to/package` (example: `go test -run '^TestListContexts$' ./internal/k8s`)
- Run tests with coverage: `go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out`
- Generate mocks: `tools/generate-mocks.sh`
- Lint: `golangci-lint run`
- Format code: `gofmt -w .` or `go fmt ./...`
- Vet code: `go vet ./...`

## Code Style Guidelines

- **Imports**: Standard Go import organization (stdlib, external, internal) with blank lines between groups
- **Error Handling**: Return errors explicitly; prefer wrapping with fmt.Errorf("context: %w", err)
- **Naming**: Use Go conventions (CamelCase for exported, camelCase for unexported)
- **Testing**: Use YAML test files in testdata directory with foxytest package
- **Types**: Use strong typing; prefer interfaces for dependencies
- **Documentation**: Document all exported functions and types with godoc comments
- **Structure**: Follow k8s-like API structure in internal/k8s package
- **Dependencies**: Use dependency injection with fx framework
- **Context**: Pass kubernetes contexts explicitly as parameters
- **Formatting**: Use gofmt standard formatting (tabs for indentation)
- **Line Length**: Keep lines under 100 characters when practical

## Comment Guidelines

- Package comments: Single line describing package purpose
- Exported functions/types: Start with the name, e.g., "FunctionName does..."
- Complex logic: Add inline comments for non-obvious operations
- TODO/FIXME: Include your name and date
- Avoid obvious comments like "increment i"
- Use complete sentences with proper punctuation

## Testing Patterns

- Write table-driven tests using t.Run() for subtests
- Use testify/assert for assertions when appropriate
- Create test fixtures in testdata directories
- Mock external dependencies using interfaces
- Test error cases thoroughly
- Use t.Helper() in test helper functions
- Prefer running specific tests with -run flag for performance
- Use golden files for complex output validation
- Always check test coverage for new code

## Error Handling

- Always check errors immediately after function calls
- Wrap errors with context using fmt.Errorf
- Define custom error types for domain-specific errors
- Use errors.Is() and errors.As() for error checking
- Return early on errors (guard clauses)
- Log errors at the appropriate level
- Never panic in library code

## Logging

- Use structured logging (e.g., slog or zerolog)
- Include relevant context in log messages
- Use appropriate log levels (Debug, Info, Warn, Error)
- Avoid logging sensitive information
- Use consistent field names across log entries

## Performance Considerations

- Profile before optimizing (pprof)
- Prefer sync.Pool for frequently allocated objects
- Use buffered channels when appropriate
- Avoid premature optimization
- Benchmark critical paths
- Consider memory allocation in hot paths
- Use context for cancellation in long-running operations

## Concurrency Patterns

- Prefer channels over shared memory
- Use sync.Mutex for protecting shared state
- Always handle goroutine lifecycle (no goroutine leaks)
- Use context.Context for cancellation propagation
- Use sync.WaitGroup or errgroup for coordinating goroutines
- Avoid starting goroutines in init()

## API Design

- Follow RESTful conventions for HTTP APIs
- Use consistent URL patterns
- Return appropriate HTTP status codes
- Use JSON for request/response bodies
- Implement proper input validation
- Version APIs appropriately
- Document API endpoints with OpenAPI/Swagger

## Security Best Practices

- Never hardcode secrets or credentials
- Validate all user input
- Use crypto/rand for security-sensitive randomness
- Follow OWASP guidelines for web applications
- Use TLS for all network communications
- Implement proper authentication and authorization

## Docker & Deployment

- Keep Docker images small using multi-stage builds
- Use non-root users in containers
- Follow 12-factor app principles
- Use environment variables for configuration
- Implement health checks
- Log to stdout/stderr

## Project Structure

```text
/app/
├── cmd/           # Main applications
├── internal/      # Private application code
├── pkg/           # Public libraries
├── testdata/      # Test fixtures
├── docs/          # Documentation
├── tools/         # Development tools
└── scripts/       # Build and utility scripts
```

## Git Workflow

- Write clear, imperative commit messages
- Keep commits focused and atomic
- Run tests before committing
- Use conventional commits format when applicable
- Squash commits when merging feature branches

## Continuous Integration

- All tests must pass before merging
- Maintain test coverage above 80%
- Run linters in CI pipeline
- Build Docker images in CI
- Use semantic versioning for releases

## Important Reminders

- Do what has been asked; nothing more, nothing less
- Never create files unless they're absolutely necessary
- Always prefer editing existing files to creating new ones
- Never proactively create documentation files unless explicitly requested
- Always run linters after making changes
- Test your code changes before considering the task complete
