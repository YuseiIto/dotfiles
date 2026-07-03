# cookbooks

This directory contains mItamae cookbooks.

Each cookbook represents a specific tool or configuration feature.
Cookbooks are kept atomic — one cookbook per tool.
Categorization is done at the role level (see [roles/](../roles/)).

Many simple cross-platform package cookbooks use the `cross_platform_package`
custom resource defined in [`lib/custom_resources.rb`](../lib/custom_resources.rb).

## Handling unsupported platforms

Every cookbook must explicitly handle each platform it supports and **fail
loudly on the rest**. When a cookbook is reached on a platform it does not
support, it must call the `unsupported_platform!` helper (defined in
[`lib/custom_resources.rb`](../lib/custom_resources.rb)) instead of silently
skipping installation:

```ruby
if node[:platform] == 'darwin'
  package 'mytool'
elsif %w[ubuntu debian].include?(node[:platform])
  # ... Linux install ...
else
  unsupported_platform! node[:platform]
end
```

Cookbooks are only ever included in roles whose platform they target, so
reaching `unsupported_platform!` means the role/platform combination is
misconfigured. Aborting the run surfaces that mistake immediately rather than
leaving a half-provisioned host. Do **not** leave a bare `if`/`elsif` without
an `else`, and do not silently `... if node[:platform] == 'darwin'` — both hide
misconfigurations behind a no-op.

The only exception is a cookbook that genuinely targets every platform via a
catch-all branch (the package manager handles the differences). In that case
name the supported platforms explicitly and still terminate with
`unsupported_platform!` for anything unexpected. The `cross_platform_package`,
`cargo_package`, `uv_tool_package`, and `npm_global_package` helpers already
embed this policy, so cookbooks built solely on them need no extra branch.
