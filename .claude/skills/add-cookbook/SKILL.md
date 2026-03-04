---
name: dotfiles-add-cookbook
description: >
  Add a new mitamae cookbook for a tool, package, LSP server, or application in this dotfiles
  repository. Use this skill whenever the user says things like "add cookbook for X", "install X
  via mitamae", "add X to dotfiles", "add LSP for X", "provision X", "set up X in my environment".
  Also trigger when the user just names a tool and implicitly expects it to be added to the repo.
---

# Add a New Mitamae Cookbook

## Before you write anything

**Step 1: Check the mitamae docs if unsure about any resource behavior.**
The official README is at: https://raw.githubusercontent.com/itamae-kitchen/mitamae/refs/heads/master/README.md
Fetch it with WebFetch when you're uncertain about resource semantics, attribute names, or execution order.

**Step 2: Research the tool's recommended installation method.**
Use WebSearch to find:
- The tool's official installation docs
- Which package managers provide it (brew, apt, cargo, pip, npm, etc.)
- Whether OS-native packages are up to date vs stale (e.g., `apt install neovim` installs a very old version — avoid it)
- The **latest stable version** if you'll pin a version number

**Step 3: Choose the installation method** using this priority order (highest to lowest):

| Priority | Method | When to use |
|----------|--------|-------------|
| 1st | `package` / `cross_platform_package` | Available via brew (macOS) or apt (Linux) AND the version is reasonably current |
| 2nd | `cargo_package` | A Rust binary; cargo gives the latest version |
| 3rd | `uv_tool_package` | A Python CLI tool |
| 4th | `npm_global_package` | A Node.js CLI tool |
| 5th | `execute` + official installer script | When package managers give stale versions or the tool isn't packaged |
| Last | sdkman or other version managers | Only when absolutely necessary |

If the apt/brew package is significantly outdated, note this explicitly and fall back to the next method.

---

## Repository structure

```
mitamae/
├── lib/custom_resources.rb   # Shared resource helpers (read this for idioms)
├── cookbooks/<name>/
│   ├── default.rb            # Installation logic (required)
│   ├── files/                # Dotfiles to symlink into $HOME
│   └── templates/            # ERB templates for generated config files
└── roles/<variant>/default.rb  # Include cookbooks here
```

Roles follow an inheritance chain: **plum → bamboo → pine**
- `plum`: bare essentials (shell, editor, base tools)
- `bamboo`: daily dev tools (git, LSPs, AI assistants)
- `pine`: specialized / hardware / niche tools

---

## Custom resource idioms

These helpers are defined in `mitamae/lib/custom_resources.rb`. Always prefer them over raw resources.

### `cross_platform_package` — system package manager (preferred)

```ruby
# Same name on both platforms:
cross_platform_package 'ripgrep'

# Different names per platform:
cross_platform_package 'sqlite',
  darwin_name: 'sqlite',
  debian_name: 'sqlite3'
```

Debian installs run as root automatically. Darwin uses brew.

### `brew_cask` — macOS GUI applications

Only available on macOS. Use for `.app` bundles (not CLI tools).

```ruby
if node[:platform] == 'darwin'
  brew_cask 'wezterm'
end
```

### `cargo_package` — Rust binaries

Automatically installs `rust` as a dependency.

```ruby
cargo_package 'eza'

# When binary name differs from crate name:
cargo_package 'bat', bin_name: 'bat'
```

### `uv_tool_package` — Python CLI tools

Automatically installs `uv` as a dependency. Never use `pip`.

```ruby
uv_tool_package 'ruff'

# When binary name differs from package name:
uv_tool_package 'python-lsp-server', bin_name: 'pylsp'
```

### `npm_global_package` — Node.js CLI tools

Automatically installs `nodenv` as a dependency and rehashes shims.

```ruby
npm_global_package 'prettier'

# With pinned version:
npm_global_package 'typescript-language-server', version: '4.3.3'

# When binary name differs from package name:
npm_global_package 'opencode-ai', bin_name: 'opencode'
```

### `dotfile` — symlink a file into $HOME

```ruby
dotfile '.tool-config' do
  cookbook_dir __dir__
end
```

File must live at `files/.tool-config` within the cookbook directory.

### `dotconfig` — symlink a directory into ~/.config

```ruby
dotconfig 'mytool'
```

Source must live at `.config/mytool/` in the repo root.

### `execute` — custom install commands

Use when none of the helpers above apply. Always add a `not_if` guard.

```ruby
execute 'install mytool' do
  command 'curl -fsSL https://example.com/install.sh | sh'
  user 'root'   # Linux only; omit on macOS
  not_if 'command -v mytool'
end
```

---

## Platform and architecture patterns

### Platform detection

```ruby
node[:platform] == 'darwin'                        # macOS
%w[ubuntu debian].include?(node[:platform])        # Debian/Ubuntu Linux
```

### Architecture

`node[:os_arch]` is already normalized by `custom_resources.rb`:
- `aarch64` / `arm64` → `'arm64'`
- `x86_64` / `amd64` → `'x86_64'`

Use it in download URLs:

```ruby
url = "https://github.com/example/releases/download/v#{version}/tool-linux-#{node[:os_arch]}.tar.gz"
```

### Multi-platform example with arch-specific binary download

```ruby
mytool_version = '1.2.3'  # Always verify this is the latest — check GitHub releases!

if node[:platform] == 'darwin'
  package 'mytool'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'install mytool' do
    command <<~EOC
      curl -fsSLO "https://github.com/example/mytool/releases/download/v#{mytool_version}/mytool-linux-#{node[:os_arch]}.tar.gz"
      tar xzf "mytool-linux-#{node[:os_arch]}.tar.gz" mytool
      install mytool /usr/local/bin/mytool
      rm -f mytool "mytool-linux-#{node[:os_arch]}.tar.gz"
    EOC
    user 'root'
    not_if "mytool --version 2>/dev/null | grep -q '#{mytool_version}'"
  end
end
```

**When pinning a version:** always search the web to confirm the latest release before hardcoding it.

---

## mruby limitations (important!)

mitamae runs on mruby, not full Ruby. Common gotchas:

| Don't use | Use instead |
|-----------|-------------|
| `Dir.home` | `ENV['HOME']` |
| `__dir__` (inconsistent) | `File.dirname(__FILE__)` |
| `require` (most stdlib) | Not available |
| String interpolation in heredoc delimiter | Use plain delimiter like `EOC` |

---

## Checklist before finishing

- [ ] `not_if` guard on every `execute` block
- [ ] Linux `execute` blocks have `user 'root'` if writing to system paths
- [ ] Both `darwin` and `debian/ubuntu` branches handled (or explicitly noted if tool is platform-exclusive)
- [ ] Both `arm64` and `x86_64` covered in any download URLs
- [ ] Version number verified against latest release (not assumed from training data)
- [ ] Cookbook added to the appropriate role(s) with `include_recipe '../../cookbooks/<name>'`
- [ ] Run `cd mitamae && bundle exec rubocop` and fix any warnings

---

## Adding to a role

Edit `mitamae/roles/<variant>/default.rb` and add:

```ruby
include_recipe '../../cookbooks/<name>'
```

Choose the most restrictive role that makes sense:
- `plum` — everyone needs this (rare)
- `bamboo` — standard dev tool
- `pine` — niche / hardware / heavy tool
