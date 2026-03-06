## Summary

<!-- What does this PR do? Keep it brief. -->

## Type of Change

- [ ] New cookbook (package/tool addition)
- [ ] Cookbook update (existing tool configuration change)
- [ ] Role change (variant tier modification)
- [ ] CI / workflow change
- [ ] Dotfile / config change (`.config/`, `.zshrc`, etc.)
- [ ] Documentation
- [ ] Bug fix
- [ ] Other

## Platforms Tested

- [ ] macOS (Apple Silicon)
- [ ] Debian / Ubuntu (aarch64)
- [ ] Debian / Ubuntu (x86_64)
- [ ] Docker (specify variant: pine / bamboo / plum)
- [ ] N/A (no platform-specific changes)

## Checklist

- [ ] `bundle exec rubocop` passes (if mitamae recipes changed)
- [ ] Idempotent: running the recipe twice produces no changes on the second run
- [ ] Platform guards (`only_if` / `not_if`) are in place where needed
- [ ] No secrets or personal tokens are included
- [ ] Documentation updated (if applicable)
- [ ] Self-checked with `/review` or similar coding agent command
