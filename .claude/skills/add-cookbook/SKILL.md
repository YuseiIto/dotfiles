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
| 5th | `github_release_binary` | A prebuilt single binary on a GitHub release (Debian/Ubuntu); macOS via brew |
| 6th | `execute` + official installer script | When package managers give stale versions or the tool isn't packaged |
| 7th | `snap` (Linux only) | Tool is officially distributed via Snap Store; macOS uses brew/cask |
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

### `apt_repository` — third-party APT repositories (Debian/Ubuntu)

Use inside the Debian/Ubuntu branch when a tool ships via its own APT repo
instead of the base distro. It fetches the signing key, normalizes it to binary
with `gpg --dearmor` (works for both armored and already-binary keys), stores it
at `/etc/apt/keyrings/<name>.gpg`, writes `/etc/apt/sources.list.d/<name>.list`
(scoped to that key via `signed-by` and pinned to the host arch), and runs
`apt-get update`. `curl`, `ca-certificates`, and `gnupg` are installed
automatically. Always prefer this over hand-rolling the key/sources/update dance
in a raw `execute` — apt's `signed-by` is extension-sensitive, and getting the
key format wrong silently breaks verification.

```ruby
apt_repository 'google-chrome' do
  key_url 'https://dl.google.com/linux/linux_signing_key.pub'
  repo 'https://dl.google.com/linux/chrome/deb/ stable main'
end

# A codename-keyed repo embeds shell directly in `repo`:
codename = '$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")'
apt_repository 'docker' do
  key_url "https://download.docker.com/linux/#{node[:platform]}/gpg"
  repo "https://download.docker.com/linux/#{node[:platform]} #{codename} stable"
end
```

`repo` is everything after the `[options]` block of the sources line. Pair it
with an explicit `package '<name>' do user 'root' end` for the actual install
and an `unsupported_platform!` fallback for other platforms.

### `github_release_binary` — prebuilt executables from GitHub releases (Debian/Ubuntu)

Use inside the Debian/Ubuntu branch when a tool ships a prebuilt binary on its
GitHub releases page and no current apt package exists. It resolves the arch
from `node[:os_arch]`, builds the `v<version>` download URL, fetches the asset,
unpacks it, and installs it to `/usr/local/bin` as root. Prefer it over a raw
`execute` heredoc — in particular, never re-derive the arch with a shell
`uname -m` case; that duplicates lib's normalization and drifts out of sync.

Upstreams spell the arch differently (`arm64` vs `aarch64`, `x86_64` vs `amd64`
vs `x64`), so pass the asset file name per arch via `arm64_name` / `x86_64_name`.
The unpack strategy is inferred from the asset extension: `.tar.gz`/`.tgz` and
`.zip` extract `archive_member` (defaults to the binary name), `.gz` gunzips a
single binary, anything else is treated as the raw executable. `curl` (plus
`unzip` for zip assets) is installed automatically. `not_if` guards the download
(usually a version check).

Pin both `arm64_sha256` and `x86_64_sha256`, each as `'<tag>@<sha256>'` and
annotated for Renovate (see [Renovate annotations](#renovate-annotations)). The
install aborts on a digest mismatch. A missing or malformed pin for the host's
arch aborts the whole mitamae run when the recipe is evaluated, even on hosts
where `not_if` would have skipped the download. Take the
digest from the upstream checksum file when one is published, otherwise hash
the downloaded asset (`curl -fsSL <url> | sha256sum`, or `shasum -a 256` on
macOS). Raw `execute` downloads verify the same way: take the digest with
`ReleasePin.for_arch(node[:os_arch], label, arm64: pin, x86_64: pin)` (or
`ReleasePin.sha256(pin, label)` for a single pin, both from
`lib/custom_resources.rb`), which aborts on a malformed pin, then check it with
`echo "<sha256>  <file>" | sha256sum -c -` (`shasum -a 256 -c -` on macOS).
Skipping `ReleasePin` on macOS lets a 40-hex pin pass as SHA-1, since `shasum`
picks the algorithm from the digest length.

```ruby
# Raw binary asset:
# renovate: datasource=github-releases depName=goss-org/goss extractVersion=^v(?<version>.+)$
goss_version = '1.2.3'

github_release_binary 'goss' do
  repo 'goss-org/goss'
  version goss_version
  arm64_name 'goss-linux-arm64'
  x86_64_name 'goss-linux-amd64'
  # renovate: datasource=github-release-attachments depName=goss-org/goss
  arm64_sha256 'v1.2.3@<sha256 of goss-linux-arm64>'
  # renovate: datasource=github-release-attachments depName=goss-org/goss
  x86_64_sha256 'v1.2.3@<sha256 of goss-linux-amd64>'
  not_if "goss --version 2>/dev/null | grep -q '#{goss_version}'"
end

# .tar.gz / .zip asset — extract one member:
# renovate: datasource=github-releases depName=jesseduffield/lazygit extractVersion=^v(?<version>.+)$
lazygit_version = '1.2.3'

github_release_binary 'lazygit' do
  repo 'jesseduffield/lazygit'
  version lazygit_version
  arm64_name "lazygit_#{lazygit_version}_Linux_arm64.tar.gz"
  x86_64_name "lazygit_#{lazygit_version}_Linux_x86_64.tar.gz"
  archive_member 'lazygit'
  # renovate: datasource=github-release-attachments depName=jesseduffield/lazygit
  arm64_sha256 'v1.2.3@<sha256 of the arm64 asset>'
  # renovate: datasource=github-release-attachments depName=jesseduffield/lazygit
  x86_64_sha256 'v1.2.3@<sha256 of the x86_64 asset>'
  not_if "lazygit --version 2>/dev/null | grep -q '#{lazygit_version}'"
end
```

macOS variants of these tools come from Homebrew, so call this only from the
Linux branch and pair it with a `package`/`unsupported_platform!` fallback. For
assets that unpack into a directory tree (extract to `/opt` + symlink) or that
are `.deb` packages (`apt-get install`), keep a raw `execute` — this helper is
for a single executable landing in `/usr/local/bin`.

### `brew_cask` — macOS GUI applications

Only available on macOS. Use for `.app` bundles (not CLI tools). Pair it with
an explicit `unsupported_platform!` fallback so the cookbook fails loudly if it
is ever reached on a non-macOS host (see "Unsupported platforms" below).

```ruby
if node[:platform] == 'darwin'
  brew_cask 'wezterm'
else
  unsupported_platform! node[:platform]
end
```

### `unsupported_platform!` — fail loudly on platforms you don't support

Always terminate platform branches with this helper instead of silently
skipping. See "Unsupported platforms" below for the full policy.

```ruby
unsupported_platform! node[:platform]
```

### `cargo_package` — Rust binaries

Automatically installs `rust` as a dependency.

```ruby
cargo_package 'eza'

# When binary name differs from crate name:
cargo_package 'ripgrep' do
  bin_name 'rg'
end
```

### `uv_tool_package` — Python CLI tools

Automatically installs `uv` as a dependency. Never use `pip`.

```ruby
uv_tool_package 'ruff'

# When binary name differs from package name:
uv_tool_package 'python-lsp-server' do
  bin_name 'pylsp'
end
```

### `npm_global_package` — Node.js CLI tools

Automatically installs `nodenv` as a dependency and rehashes shims.

```ruby
npm_global_package 'prettier'

# With pinned version:
# renovate: datasource=npm depName=typescript-language-server
typescript_language_server_version = '4.3.3'

npm_global_package 'typescript-language-server' do
  version typescript_language_server_version
end

# When binary name differs from package name:
npm_global_package 'opencode-ai' do
  bin_name 'opencode'
end
```

Set attributes in the block: a definition takes only its name as an argument,
so `npm_global_package 'x', version: '...'` raises.

### `dotfile` — symlink a file into $HOME

```ruby
dotfile '.tool-config' do
  cookbook_dir File.dirname(__FILE__)
end
```

File must live at `files/.tool-config` within the cookbook directory.

### `dotconfig` — symlink a directory into ~/.config

```ruby
dotconfig 'mytool'
```

Source must live at `.config/mytool/` in the repo root.

### `snap` — Linux snap packages (macOS: use brew/cask instead)

Install `snapd` first, then `snap install`. Always specify `--classic` when the tool requires it (check the Snap Store page).

```ruby
if node[:platform] == 'darwin'
  brew_cask 'mytool'  # or package/brew equivalent
elsif %w[ubuntu debian].include?(node[:platform])
  package 'snapd' do
    user 'root'
  end

  execute 'Install mytool via snap' do
    command 'snap install mytool --classic'
    user 'root'
    not_if 'snap list | grep -q mytool'
  end
else
  unsupported_platform! node[:platform]
end
```

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

### Unsupported platforms (required)

Every cookbook must handle each platform it supports explicitly and **fail
loudly on the rest** by calling `unsupported_platform! node[:platform]`. Never
leave a bare `if`/`elsif` without an `else`, and never write
`... if node[:platform] == 'darwin'` as a silent guard — both hide
role/platform misconfigurations behind a no-op.

```ruby
if node[:platform] == 'darwin'
  package 'mytool'
elsif %w[ubuntu debian].include?(node[:platform])
  # ... Linux install ...
else
  unsupported_platform! node[:platform]
end
```

Cookbooks built solely on `cross_platform_package`, `cargo_package`,
`uv_tool_package`, or `npm_global_package` already embed this policy and need no
extra branch.

### Architecture

`node[:os_arch]` is already normalized by `custom_resources.rb`:
- `aarch64` / `arm64` → `'arm64'`
- `x86_64` / `amd64` → `'x86_64'`

Use it in download URLs:

```ruby
url = "https://github.com/example/releases/download/v#{version}/tool-linux-#{node[:os_arch]}.tar.gz"
```

### Multi-platform example with arch-specific binary download

Reach for `github_release_binary` (see its idiom above) whenever the Linux asset
is a single executable — it resolves the arch and handles the download/unpack:

```ruby
# renovate: datasource=github-releases depName=example/mytool extractVersion=^v(?<version>.+)$
mytool_version = '1.2.3'

if node[:platform] == 'darwin'
  package 'mytool'
elsif %w[ubuntu debian].include?(node[:platform])
  github_release_binary 'mytool' do
    repo 'example/mytool'
    version mytool_version
    arm64_name "mytool-linux-arm64.tar.gz"
    x86_64_name "mytool-linux-x86_64.tar.gz"
    archive_member 'mytool'
    # renovate: datasource=github-release-attachments depName=example/mytool
    arm64_sha256 'v1.2.3@<sha256 of mytool-linux-arm64.tar.gz>'
    # renovate: datasource=github-release-attachments depName=example/mytool
    x86_64_sha256 'v1.2.3@<sha256 of mytool-linux-x86_64.tar.gz>'
    not_if "mytool --version 2>/dev/null | grep -q '#{mytool_version}'"
  end
else
  unsupported_platform! node[:platform]
end
```

**When first pinning a version:** search the web to confirm the latest
release; Renovate keeps it current after that.

### Renovate annotations

Put a `# renovate:` annotation on the line directly above every pin so
Renovate keeps it current. renovate.json's `matchStrings` read only the keys
and order shown below, so add no other key (`versioning=`, `packageName=`, ...);
`make check-version-pins` rejects any other shape:

- `<name>_version = '...'` constants: name the datasource and the upstream as
  `depName`; add `extractVersion` when the release tag differs from the stored
  value (e.g. `^v(?<version>.+)$` for `v`-prefixed tags). Keep versions in
  these constants, never as literals inside a resource, which no manager reads.
  Write the constant exactly as `<name>_version = '...'` (lowercase name, one
  space around `=`, single quotes): neither the matchString nor
  `make check-version-pins` sees any other spelling, so such a pin goes
  untracked without failing the check.
- `'<tag>@<sha256>'` digest pins: use
  `datasource=github-release-attachments depName=<owner/repo>`, and write
  `<tag>` as the exact release tag (`v1.2.3`, not `1.2.3`, when upstream tags
  with a `v`). Renovate finds the pinned asset in that release (a wrong tag
  fails the lookup) and hashes the new release's asset whose name has the
  version replaced.

Run `make check-version-pins` after adding a pin; the header of
`scripts/check-version-pins.sh` lists what it rejects.

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

## Goss assertion

Every cookbook must have a `goss.yaml` for health-check validation. **Prefer `command` checks over `file` checks** — command checks work identically on macOS and Linux regardless of installation path differences.

```yaml
# Preferred: verify the binary is runnable (platform-agnostic)
command:
  mytool --version:
    exit-status: 0
    timeout: 5000
```

Only use `file` checks for non-executable artifacts (symlinked dotfiles, config directories, etc.) that have no runnable command.

The goss validate step exports these directories to PATH automatically, so command checks will find binaries installed by any method:
- `~/.cargo/bin` (cargo_package)
- `~/.local/bin` (uv_tool_package)
- `~/.nodenv/shims` and `~/.nodenv/bin` (npm_global_package)

After creating `cookbooks/<name>/goss.yaml`, register it in the role's goss.yaml:

```yaml
# mitamae/roles/<variant>/goss.yaml
gossfile:
  ../../cookbooks/<name>/goss.yaml: {}
```

---

## LSP server registration

When the cookbook installs an LSP server binary, also register it in `.config/nvim/lua/lsp/languages.lua`.

**Step 1:** Look up the server name in the nvim-lspconfig docs:
`https://raw.githubusercontent.com/neovim/nvim-lspconfig/refs/heads/master/doc/configs.md`

**Step 2:** Add the minimal registration at the bottom of the file:

```lua
-- mytool LSP
-- https://github.com/example/mytool-lsp
vim.lsp.enable('mytool_lsp')
```

**Step 3:** If the LSP conflicts with a formatter (e.g., ts_ls + biome), disable its formatting capability:

```lua
vim.lsp.config('mytool_lsp', {
  on_attach = disable_formatting,
})
vim.lsp.enable('mytool_lsp')
```

The `disable_formatting` helper is already defined at the top of the file.

---

## Checklist before finishing

- [ ] `not_if` guard on every `execute` block
- [ ] Linux `execute` blocks have `user 'root'` if writing to system paths
- [ ] Both `darwin` and `debian/ubuntu` branches handled (or explicitly noted if tool is platform-exclusive)
- [ ] Both `arm64` and `x86_64` covered in any download URLs
- [ ] Version number verified against latest release (not assumed from training data)
- [ ] Cookbook added to the appropriate role(s) with `include_recipe '../../cookbooks/<name>'`
- [ ] `goss.yaml` created and registered in the role's `goss.yaml`
- [ ] If an LSP server: registered in `.config/nvim/lua/lsp/languages.lua`
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
