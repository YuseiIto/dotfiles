# Security Policy
## Supported Versions
This project operates on a "works for me" basis. No formal support is offered.

_Feel free to reach out if you encounter any difficulties! 🌞_

## Secrets Policy
This repository is public. No secrets — API keys, tokens, passwords, private keys, or any other credential — are ever committed to it.

- Sensitive values are kept outside the repository and supplied at provisioning or runtime (e.g. via the environment or local, untracked files in `$HOME`).
- Recipes and configuration reference secrets by location, never by value.
- If a secret is ever committed by mistake, treat it as compromised: rotate it immediately, then purge it from the history.

## Reporting a Vulnerability
Vulnerabilities can be reported via email to [@yuseiito](https://github.com/yuseiito) (check the GitHub profile for the actual address) or, if it's deemed safe to disclose, by posting them on the [issues page](https://github.com/YuseiIto/dotfiles/issues).
