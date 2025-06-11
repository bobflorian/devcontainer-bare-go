#!/bin/bash
set -e

echo "Installing Claude Code..."

# Install Node.js if not already installed
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get update
    apt-get -y install nodejs
fi

# Setup for root user since vscode user doesn't exist
# Don't use hardcoded usernames that may not exist
mkdir -p /root/.npm-global
npm config set prefix /root/.npm-global

# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Add to PATH in shell profiles
echo 'export PATH=/root/.npm-global/bin:$PATH' >> /root/.bashrc
if [ -f "/root/.zshrc" ]; then
    echo 'export PATH=/root/.npm-global/bin:$PATH' >> /root/.zshrc
fi

# Make it available right away
export PATH=/root/.npm-global/bin:$PATH

echo "Claude Code installed successfully!"
