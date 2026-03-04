# 🏯 dotfiles

Welcome to my cockpit. This repository is more than just a collection of config files; it's a meticulously crafted environment for software engineering, embedded development, and AI-assisted productivity.

## 🍱 The Variants (松竹梅)

I categorize my environments using the Japanese *Sho-Chiku-Bai* (Pine, Bamboo, Plum) tiers. This classification helps in choosing the right tool density for the job at hand.

| Variant | Name | Description | Best For |
| :--- | :--- | :--- | :--- |
| **Pine** (松) | Full House | The ultimate development environment. Includes all compilers, LSPs, hardware tools, and AI agents. | High-performance workstations and comprehensive development. |
| **Bamboo** (竹) | Balanced | A curated set of essential engineering tools. Efficient and fast without the overhead of niche packages. | Daily coding and standard DevOps tasks. |
| **Plum** (梅) | Minimal | The bare essentials. A high-performance terminal, shell, and editor with minimal dependencies. | Remote servers and resource-constrained environments. |

For detailed variant specifications, see [VARIANTS.md](docs/VARIANTS.md).

---

## 🚀 Quick Start

### 🐳 Try NOW with Prebuilt Docker Images

I maintain prebuilt images so you can jump into my environment without messing up your own.

```zsh
# Pick your variant:
docker run --rm -it ghcr.io/yuseiito/yuseiito-dev:pine-latest   # Everything included
docker run --rm -it ghcr.io/yuseiito/yuseiito-dev:bamboo-latest # The daily driver
docker run --rm -it ghcr.io/yuseiito/yuseiito-dev:plum-latest   # Fast and light
```

> **Note:** `pine` is quite substantial in size. For a quick trial, the `bamboo` variant is usually the sweet spot.

---

## 🤖 AI-First Development

This repository is designed to be navigated and enhanced by **Coding Agents** (like Claude Code, Codex, Gemini CLI, or OpenCode).

- **Agent Integration:** Predefined recipes and clear instructions ar prepared. It allows AI agents to act as first-class contributors.
- **Self-Documenting:** If you're exploring the repository, your AI agent can navigate the `mitamae` cookbooks to explain exactly what's being installed.

---

## 🏗 Structure

- `.config/`: XDG-style configurations (Neovim, Alacritty, etc.).
- `mitamae/`: Idempotent provisioning via [mItamae](https://github.com/itamae-kitchen/mitamae).
  - `cookbooks/`: Individual tool recipes.
  - `roles/`: Collections of cookbooks (Pine, Bamboo, Plum, Belle).
- `docker/`: Dockerfiles for the containerized environments.

---

*Handcrafted with ❤️ and a lot of ☕ by [yuseiito](https://yuseiito.com/).*
