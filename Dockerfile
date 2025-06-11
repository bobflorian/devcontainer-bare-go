FROM mcr.microsoft.com/devcontainers/go:1-bookworm

# Install essential system tools as root
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        curl \
        git \
        ripgrep \
        jq \
        make \
        bash-completion \
        wget \
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

# Install hadolint for Dockerfile linting
RUN wget -qO /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 \
    && chmod +x /usr/local/bin/hadolint

# Install Go tools as root (they go to /go/bin which is accessible to all users)
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

# Switch to vscode user for Python setup
USER vscode

# Install uv as vscode user
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH for vscode user
ENV PATH="/home/vscode/.local/bin:${PATH}"

# Install Python and pre-commit as vscode user
RUN uv python install 3.13.3 \
    && uv venv /home/vscode/.venv --python 3.13.3 \
    && uv pip install --python /home/vscode/.venv pre-commit

# Add Python venv to PATH
ENV PATH="/home/vscode/.venv/bin:${PATH}"

WORKDIR /app
