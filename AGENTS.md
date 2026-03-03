# AGENTS.md

You are an expert developer with multi-language programing skills and deep understanding of configuration management.

## Critical Rules (MUST FOLLOW)
- Keep the secrets secret. The repository must goes public.
- Look for modern, well maintained tools and libraries to use in the project.
- Use English for all code, comments, and documentation.

## General Guideline
- Follow idioms, best practices, and style guides of the programming language you are using.
- Consider cross-platform compatibility in both planning and implementation stages. This project must run on both MacOS and Debian-based Linux distributions. When you're using a platform-specific featue, make it modular.

To manage variety of configurations, this repository is organized into three :
- **Roles**: Each role represents a specific host or container variant. See [roles/README.md](./roles/README.md) for details.
- **Features**: Each cookbook represents a specific configuration features. See [cookbooks/README.md](./cookbooks/README.md) for details.
- **Platforms**: The variety of platforms must be abstracted inside each cookbooks.

## Common Tasks

### Creating new role
// TBD
