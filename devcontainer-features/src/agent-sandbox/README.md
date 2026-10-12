# Agent sandbox (`agent-sandbox`)

Hardens a dev container so a coding agent can run with permission prompts
disabled (`claude --dangerously-skip-permissions`) with a limited blast radius.

- **Egress allowlist.** dnsmasq resolves only allowlisted domains (and their
  subdomains) and adds the answers to an ipset; iptables permits TCP 80/443 to
  that set and rejects everything else. Only dnsmasq may query the upstream
  resolver, so DNS cannot be used as a side channel. All IPv6 traffic except
  loopback is dropped.
- **Restricted sudo.** The remote user may run only the firewall script via
  sudo, so it cannot flush the rules. Every start re-checks this.
- **Persistent Claude Code state.** One named volume holds the Claude Code
  config directory (`CLAUDE_CONFIG_DIR`), shared by every project, so `/login`
  happens once per machine and survives rebuilds.
- **Managed settings** (`/etc/claude-code/managed-settings.json`, root-owned):
  only managed hooks run, and claude.ai connectors are either disabled or
  have their write-style tools forced to prompt.

## Usage

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "remoteUser": "vscode",
  "features": {
    "ghcr.io/yuseiito/dotfiles/agent-sandbox:1": {}
  },
  "remoteEnv": {
    "GH_TOKEN": "${localEnv:GH_TOKEN}"
  },
  // Do not start shells or agents before the firewall is up.
  "waitFor": "postStartCommand"
}
```

The remote user must be non-root; Claude Code refuses
`--dangerously-skip-permissions` as root.

## Options

| Option | Type | Default | Description |
|---|---|---|---|
| `allowedDomains` | string | `""` | Comma-separated extra domains to allow (subdomains included). Scheme and path are stripped; invalid entries fail the build. |
| `allowHostNetwork` | boolean | `false` | Allow traffic to the Docker host's /24 network. |
| `restrictSudo` | boolean | `true` | Remove the remote user's sudo rights except running the firewall script. |
| `allowClaudeAiConnectors` | boolean | `false` | Keep claude.ai connectors enabled and allow `mcp-proxy.anthropic.com`. |
| `connectorAskRules` | string | write-style globs | Comma-separated permission rules written to managed `permissions.ask` when connectors are allowed. Ask rules prompt even with `--dangerously-skip-permissions`. |

The default allowlist lives in [`allowed-domains`](allowed-domains) and covers
Claude Code, GitHub, npm, PyPI, crates.io, RubyGems, the Go module proxy,
Ubuntu mirrors and VS Code.

## Authentication

- **Claude Code:** run `claude` and `/login` once. The login is stored in the
  `agent-sandbox-claude-config` volume and reused by every project.
- **GitHub:** create a [fine-grained personal access token](https://github.com/settings/personal-access-tokens)
  scoped to the repositories you work on, export it as `GH_TOKEN` on the host,
  and run `gh auth setup-git` in the container. Do not mount `~/.ssh`.

claude.ai connector tools set to "needs approval" in your personal claude.ai
settings are **not** enforced in a `--dangerously-skip-permissions` session.
Use `connectorAskRules` instead.

## Known limitations

- **Shared CDN IPs.** Allowing a CDN-hosted domain allows its IPs, and so any
  other site served from the same IPs.
- **Allowed destinations remain exfiltration channels.** Anything the agent
  can write to (GitHub with your token, connectors with write tools allowed)
  can carry data out.
- **Shared config volume.** A compromised project can read other projects'
  transcripts and prompt history, plant auto-memory content that other
  projects later read, and persist commands that later run in other
  projects: user-scope MCP servers in the shared `.claude.json`, helper
  commands such as `apiKeyHelper` in the shared `settings.json`, and plugin
  components other than hooks. Hooks and `statusLine` are blocked by
  `allowManagedHooksOnly`.
- **Verb-based connector rules.** A write tool whose name matches none of the
  `connectorAskRules` globs runs without a prompt.
- **Restarts outside dev container tooling.** `docker restart` clears the
  firewall rules; they come back only when `postStartCommand` runs again (VS
  Code or `devcontainer up`).
- **One remote-user UID per volume.** The config volume is seeded with the
  remote user's ownership the first time it is mounted. Images whose remote
  user has a different UID cannot write it.
- **Ipset growth.** Resolved IPs are never removed from the allowed set while
  the container runs.
- Container escapes through kernel bugs are out of scope.

## Maintenance

The remote user cannot become root. Use `docker exec -u root <container> bash`
from the host. To change the allowlist at runtime, edit
`/etc/agent-sandbox/allowed-domains.d/` as root and re-run
`/usr/local/share/agent-sandbox/init-firewall.sh`.
