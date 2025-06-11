FROM mcr.microsoft.com/devcontainers/go:1-bookworm

# Install essential system tools
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        curl \
        git \
        ripgrep \
        jq \
        make \
        bash-completion \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20+ (required for latest npm and Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Install Claude Code globally for the user
RUN npm install -g @anthropic-ai/claude-code

# Install just command runner
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# Install Go tools
RUN go install -v golang.org/x/tools/gopls@latest \
    && go install -v github.com/go-delve/delve/cmd/dlv@latest \
    && go install -v github.com/golangci/golangci-lint/cmd/golangci-lint@latest \
    && go install -v github.com/air-verse/air@latest \
    && go install -v mvdan.cc/gofumpt@latest \
    && go install -v golang.org/x/tools/cmd/goimports@latest \
    && go install -v github.com/segmentio/golines@latest \
    && go install -v github.com/sonatype-nexus-community/nancy@latest \
    && go install -v golang.org/x/vuln/cmd/govulncheck@latest

# Set Go environment
ENV GO111MODULE=on \
    GOPROXY=https://proxy.golang.org,direct \
    GOPRIVATE=github.com/your-org/* \
    CGO_ENABLED=1

# Switch to non-root user
USER vscode

WORKDIR /app
