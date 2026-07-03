# shellcheck shell=sh
# Shared shell environment: PATH and exported variables, sourced by both zsh
# (~/.zshenv) and bash (~/.bashrc). Pure POSIX sh — this file is sourced, no shebang.

# Force XDG default so macOS-aware tools (e.g. lazygit) use ~/.config instead of
# ~/Library/Application Support. XDG_CONFIG_HOME defaults to ~/.config when unset,
# so this is a no-op for tools that already check XDG.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# nodenv
if [ -d "$HOME/.nodenv" ]; then
  export PATH="$HOME/.nodenv/shims:$HOME/.nodenv/bin:${PATH}"
fi

# rbenv (Ruby version manager — shims expose ruby, gem, bundle, rubocop)
if [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:${PATH}"
fi

# Rust (cargo-installed binaries, rustc, cargo, etc.)
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:${PATH}"
fi

# uv-based tools and other user-local binaries (uv, aider, hf, pylsp, etc.)
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:${PATH}"
fi

# sdkman-managed tools (kotlin, java, etc.)
if [ -d "$HOME/.sdkman/candidates" ]; then
  for candidate_dir in "$HOME/.sdkman/candidates"/*/current/bin; do
    [ -d "$candidate_dir" ] && PATH="${candidate_dir}:${PATH}"
  done
  export PATH
fi

# opam (OCaml — ocaml, dune, ocamllsp). opam manages more than PATH (CAML_LD_LIBRARY_PATH,
# OPAM_SWITCH_PREFIX, ...), so eval its env instead of hardcoding a bin dir. --shell=sh keeps
# the output POSIX, valid under both bash and zsh. No-op when opam is absent.
if command -v opam >/dev/null 2>&1; then
  eval "$(opam env --shell=sh 2>/dev/null)"
fi

# MySQL client (keg-only on Homebrew, not symlinked by default)
if [ -d "/opt/homebrew/opt/mysql-client/bin" ]; then
  export PATH="/opt/homebrew/opt/mysql-client/bin:${PATH}"
fi
