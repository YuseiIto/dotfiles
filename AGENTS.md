# AGENTS.md

You are an expert developer with multi-language programming skills and deep understanding of configuration management.

## Critical Rules (MUST FOLLOW)
- Keep the secrets secret. The repository must goes public.
- Look for modern, well maintained tools and libraries to use in the project.
- Use English for all code, comments, and documentation.

## General Guideline
- Follow idioms, best practices, and style guides of the programming language you are using.
- Consider cross-platform compatibility in both planning and implementation stages. This project must run on both MacOS and Debian-based Linux distributions. When you're using a platform-specific feature, make it modular.
- When you're unsure about the mitamae's behavior, refer to the [official documentation](https://raw.githubusercontent.com/itamae-kitchen/mitamae/refs/heads/master/README.md).
- Frequently run `cd mitamae && bundle exec rubocop` to check the code style.

To manage variety of configurations, this repository is organized into three :
- **Roles**: Each role represents a specific host or container variant. See [roles/README.md](./mitamae/roles/README.md) for details.
- **Features**: Each cookbook represents a specific configuration features. See [cookbooks/README.md](./mitamae/cookbooks/README.md) for details.
- **Platforms**: The variety of platforms must be abstracted inside each cookbooks.


## Common Tasks

### Creating new role
// TBD

## Adding new package

Use the `dotfiles-add-cookbook` skill (`.claude/skills/add-cookbook/SKILL.md`) for step-by-step guidance on installation patterns, platform handling, and role assignment.
