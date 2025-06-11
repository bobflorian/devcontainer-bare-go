# Go + Claude Code Development Container
# Based on Microsoft's approach with batteries included
ARG VARIANT=1.24-bookworm
FROM golang:${VARIANT}

# Ensure bash is available
RUN apt-get update && apt-get install -y bash

# Install system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        # Basic tools
        curl \
        ca-certificates \
        gnupg \
        lsb-release \
        sudo \
        # Build tools
        build-essential \
        # Git (ensure latest version)
        git \
        # For Claude Code file search
        ripgrep \
        # Utilities
        jq \
        unzip \
        htop \
        vim \
        # Ensure shells are available
        bash \
        zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20+ (required for latest npm and Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Install GitHub CLI (optional but recommended for Claude Code)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y

# Install just command runner
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# Install Go development tools
RUN go install -v golang.org/x/tools/gopls@latest && \
    go install -v github.com/go-delve/delve/cmd/dlv@latest && \
    go install -v honnef.co/go/tools/cmd/staticcheck@latest && \
    go install -v github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
    go install -v github.com/air-verse/air@latest && \
    go install -v mvdan.cc/gofumpt@latest && \
    go install -v github.com/securego/gosec/v2/cmd/gosec@latest && \
    go install -v golang.org/x/vuln/cmd/govulncheck@latest

# Create non-root user with sudo access
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create user with explicit shell
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up workspace directory
WORKDIR /workspace
RUN chown -R $USERNAME:$USERNAME /workspace

# Ensure shell binaries are executable
RUN chmod +x /bin/bash /bin/sh

# Switch to non-root user
USER $USERNAME

# Set up user environment
ENV USER=$USERNAME
ENV HOME=/home/$USERNAME
ENV SHELL=/bin/bash

# Configure npm to use user directory for global packages
RUN mkdir -p /home/$USERNAME/.npm-global && \
    npm config set prefix '/home/developer/.npm-global' && \
    echo 'export PATH="/home/developer/.npm-global/bin:$PATH"' >> /home/$USERNAME/.bashrc

# Install Claude Code globally for the user
RUN npm install -g @anthropic-ai/claude-code

# Set up Go environment
ENV GO111MODULE=on \
    GOPATH=/home/$USERNAME/go \
    PATH="/home/$USERNAME/.npm-global/bin:/home/$USERNAME/go/bin:/usr/local/go/bin:${PATH}"

# Ensure Go binaries are in user's directory
RUN mkdir -p /home/$USERNAME/go/bin && \
    sudo cp -r /go/bin/* /home/$USERNAME/go/bin/ || true && \
    sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/go

# Create .bashrc with proper permissions
RUN touch /home/$USERNAME/.bashrc && \
    chmod 644 /home/$USERNAME/.bashrc && \
    echo 'export PATH="/home/developer/.npm-global/bin:/home/developer/go/bin:/usr/local/go/bin:${PATH}"' >> /home/$USERNAME/.bashrc && \
    echo 'alias ll="ls -la"' >> /home/$USERNAME/.bashrc && \
    echo 'alias gs="git status"' >> /home/$USERNAME/.bashrc && \
    echo 'alias gp="git pull"' >> /home/$USERNAME/.bashrc && \
    echo 'alias gc="git commit"' >> /home/$USERNAME/.bashrc && \
    echo 'alias build-all="just build-all"' >> /home/$USERNAME/.bashrc

# VS Code Go extension port
EXPOSE 9000

# Use bash as the default shell
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/bin/bash"]

# Keep container running for development
CMD ["-c", "while true; do sleep 1000; done"]