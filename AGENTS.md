# AGENTS.md

You are an expert developer with multi-language programing skills and deep understanding of configuration management.

## Critical Rules (MUST FOLLOW)
- Keep the secrets secret. The repository must goes public.
- Look for modern, well maintained tools and libraries to use in the project.
- Use English for all code, comments, and documentation.

## General Guideline
- Follow idioms, best practices, and style guides of the programming language you are using.
- Consider cross-platform compatibility in both planning and implementation stages. This project must run on both MacOS and Debian-based Linux distributions. When you're using a platform-specific featue, make it modular.
- When you're unsure about the mitamae's behavior, refer to the [official documentation](https://raw.githubusercontent.com/itamae-kitchen/mitamae/refs/heads/master/README.md).

To manage variety of configurations, this repository is organized into three :
- **Roles**: Each role represents a specific host or container variant. See [roles/README.md](./mitamae/roles/README.md) for details.
- **Features**: Each cookbook represents a specific configuration features. See [cookbooks/README.md](./mitamae/cookbooks/README.md) for details.
- **Platforms**: The variety of platforms must be abstracted inside each cookbooks.

## Common Tasks

### Creating new role
// TBD

## Adding new package
1. Create @mitamae/cookbooks/`<package-name>` directory.
2. Create `default.rb` file in the directory and add the installation logic for the package.
    - If the package is available in the system package manager, use `package` resource to install it.
    - If the package is not available in the system package manager, use `execute` resource to run the installation command (e.g., using `curl` or `wget` to download and install the package).
    - Make sure to handle platform-specific installation logic if necessary (e.g., different commands for MacOS and Debian-based Linux).
    - Take care of multiple platforms. Both aarch64 and x86_64. Both debian/ubundu and macos.
    - Use `not_if` or `only_if` guards to prevent unnecessary installations if the package is already installed.
    - If the package requires associated configuration files, create those inside the `file` directory of each cookbook.
3. Add the package to the appropriate role(s) in `roles/` directory by adding `include_recipe` statement in the role's `default.rb` file.
