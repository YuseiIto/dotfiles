# Variants

This repository offers three distinct configuration variants to cater to different development needs and resource constraints. Each variant is designed with specific use cases in mind, allowing us to choose the one that best fits their workflow and environment.

### Pine (Full-Featured / AI-Native)

The Pine variant is the most comprehensive configuration, designed for modern, AI-assisted development. It enables all available tools, language servers, and AI coding agents without limiting resource consumption.

* **Target Use Case:** Primary local development machines or high-performance cloud workstations. Suitable for autonomous coding by AI agents and resource-intensive development.
* **Key Features:** Full Neovim plugin suite (including AI assistants), comprehensive Language Server Protocol (LSP) setups, heavy runtimes, and rich shell prompts.

### Bamboo (Standard Development)

The Bamboo variant is the balanced configuration optimized for standard development by human engineers. It provides essential code intelligence and operational tools while avoiding excessive resource overhead.

* **Target Use Case:** General software development, infrastructure management, and standard coding tasks.
* **Key Features:** Essential Neovim plugins (e.g., syntax parsing, fuzzy finders), standard LSPs, and common CLI tools for infrastructure and cloud operations.

### Plum (Minimal / Maintenance)

The Plum variant is the most lightweight configuration. It strictly avoids background processes, LSPs, and heavy external runtimes, focusing entirely on immediate responsiveness and minimal footprint.

* **Target Use Case:** Resource-constrained environments such as a small VPS or single-board computers. Ideal for quick configuration edits or system troubleshooting.
* **Key Features:** Basic operational CLI tools (curl, git, tmux, ripgrep) and a minimal Neovim setup limited to syntax highlighting and basic editing. 
