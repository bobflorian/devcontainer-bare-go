# Go Bare DevContainer

[![Build Status](https://github.com/bobflorian/go-bare-devcontainer/workflows/Build/badge.svg)](https://github.com/bobflorian/go-bare-devcontainer/actions)
[![Go Report Card](https://goreportcard.com/badge/github.com/bobflorian/go-bare-devcontainer)](https://goreportcard.com/report/github.com/bobflorian/go-bare-devcontainer)
[![codecov](https://codecov.io/gh/bobflorian/go-bare-devcontainer/branch/main/graph/badge.svg)](https://codecov.io/gh/bobflorian/go-bare-devcontainer)
[![Go Reference](https://pkg.go.dev/badge/github.com/bobflorian/go-bare-devcontainer.svg)](https://pkg.go.dev/github.com/bobflorian/go-bare-devcontainer)

A minimal Go application template with DevContainer support, featuring system information display and cross-platform builds.

## Features

- 🔧 **DevContainer Ready**: Complete development environment with Docker
- 🏗️ **Cross-Platform Builds**: Linux, macOS, Windows (AMD64 & ARM64)
- 🧪 **Testing & Coverage**: Comprehensive test setup with coverage reporting
- 🔍 **Linting & Formatting**: golangci-lint, goimports, gofumpt integration
- 🛡️ **Security Auditing**: Vulnerability scanning with nancy and govulncheck
- 🚀 **CI/CD**: GitHub Actions workflow for automated builds
- 📊 **System Info Display**: Runtime system information and version details

## Quick Start

### Using DevContainer (Recommended)

1. Open in VS Code with DevContainer extension
2. Command Palette → "Dev Containers: Reopen in Container"
3. Run the application:
   ```bash
   just run
   ```

### Local Development

**Prerequisites:**
- Go 1.24.3+
- [just](https://github.com/casey/just) command runner

**Setup:**
```bash
git clone https://github.com/bobflorian/go-bare-devcontainer.git
cd go-bare-devcontainer
just deps    # Update dependencies
just run     # Build and run
```

## Usage

The application displays system information and demonstrates a basic Go project structure:

```bash
$ just run
Hello, World!

=== Application Info ===
Version:     dev
Build Time:  unknown
Commit:      unknown

=== System Info ===
OS:          linux
Architecture: amd64
CPU Cores:   8
Go Version:  go1.24.3
Hostname:    container-123
Current Time: 2025-01-06 15:30:45

✅ Go application is running successfully!
```

## Development Commands

| Command | Description |
|---------|-------------|
| `just build` | Build single binary |
| `just build-all` | Cross-platform builds for all targets |
| `just test` | Run tests |
| `just cover` | Generate coverage report |
| `just check` | Format and lint code |
| `just verify` | Quick format, lint, and test |
| `just dev` | Run with hot reload (requires air) |
| `just debug` | Run with delve debugger |
| `just audit` | Security vulnerability scan |
| `just clean` | Clean build artifacts |
| `just deps` | Update dependencies |

## Build Targets

The `just build-all` command creates binaries for:

- **Linux**: AMD64, ARM64
- **macOS**: AMD64, ARM64 (Intel & Apple Silicon)
- **Windows**: AMD64

All binaries are output to the `bin/` directory.

## Project Structure

```
├── cmd/myapp/          # Application entrypoint
├── .devcontainer/      # DevContainer configuration
├── .github/workflows/  # CI/CD workflows
├── bin/               # Built binaries
├── coverage.html      # Test coverage report
├── go.mod            # Go module definition
├── justfile          # Command runner recipes
├── Dockerfile        # Container build instructions
└── .golangci.yml     # Linter configuration
```

## Testing

```bash
# Run all tests
just test

# Run tests with coverage
just cover

# View coverage report
open coverage.html
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and linting (`just verify`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Environment

This project uses DevContainers for consistent development environments. The container includes:

- Go 1.24.3
- Development tools (golangci-lint, air, delve, etc.)
- Security audit tools (nancy, govulncheck)
- VS Code extensions for Go development

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Go and modern development practices
- DevContainer setup for consistent development environments
- Comprehensive CI/CD pipeline with GitHub Actions