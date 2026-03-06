#!/bin/zsh
# ~/.zshenv is sourced by zsh for ALL invocations: login, non-login, interactive, non-interactive.
# Keep only PATH and environment variable exports here.

# nodenv
if [ -d "$HOME/.nodenv" ]; then
  export PATH="$HOME/.nodenv/shims:$HOME/.nodenv/bin:${PATH}"
fi

# Rust (cargo-installed binaries, rustc, cargo, etc.)
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:${PATH}"
fi

# uv-based tools and other user-local binaries (uv, aider, hf, pylsp, etc.)
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:${PATH}"
fi

# MySQL client (keg-only on Homebrew, not symlinked by default)
if [ -d "/opt/homebrew/opt/mysql-client/bin" ]; then
  export PATH="/opt/homebrew/opt/mysql-client/bin:${PATH}"
fi
