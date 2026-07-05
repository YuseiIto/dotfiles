# Package audit

mitamae is a **convergent** provisioner: it guarantees declared packages are
*present*, but on its own it cannot guarantee that undeclared packages are
*absent*. A package someone installed by hand (or that lingered from an old
cookbook) stays on the machine forever, invisible to the recipes.

`scripts/audit-packages.sh` closes that gap by detecting drift:

```
drift = installed_manual_packages - declared_packages - baseline
```

- **declared** — every `package[...]` and Homebrew cask mitamae would manage for
  the role, derived automatically from the recipes via a dry run
  (`mitamae --dry-run -l debug`). The recipes remain the single source of truth;
  there is no hand-kept list of "my" packages to maintain, and both
  `cross_platform_package` and raw `package` resources are captured.
- **baseline** — packages that legitimately exist outside mitamae's control:
  the base image seed and any one-offs you have explicitly accepted. Stored in
  `baseline.<role>.txt` (keyed by role, because each role's base image seeds a
  different set, e.g. Ubuntu noble vs Debian bookworm).
- **drift** — whatever is left is unexplained. Resolve each entry by adding a
  cookbook for it, adding it to the baseline, or removing the package.

The audit is **detect-and-report only**. It never installs or removes anything.

## Usage

```sh
# Report drift for the current host's role (exit 1 if any drift):
make audit
# or, for a specific role:
DOTFILES_ROLE=plum scripts/audit-packages.sh

# Accept the current state as the baseline (run once on a known-good host,
# then commit the generated baseline.<role>.txt):
make audit-baseline

# Print the declared set and exit:
scripts/audit-packages.sh --list-declared
```

## Establishing a baseline

A fresh role base image already has many manually-installed packages (the OS
seed). The first audit on a new role will report all of them. To establish the
known-good starting point:

1. Provision the role from a clean base image (`./setup.sh`).
2. Run `make audit-baseline` to capture `installed - declared` into
   `baseline.<role>.txt`.
3. Commit that file. From then on, `make audit` reports only **new** drift —
   anything installed afterwards that is neither declared nor baselined.

## Platforms

- **Debian/Ubuntu** — manual packages come from `apt-mark showmanual`
  (automatic dependencies are excluded).
- **macOS** — from `brew leaves --installed-on-request` plus
  `brew list --cask`.

Non-system package managers (npm, gem, pip) may appear in the declared set; they
simply never match the system package list and are harmless.
