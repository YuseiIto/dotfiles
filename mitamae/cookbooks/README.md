# cookbooks

This directory contains mItamae cookbooks.

Each cookbook represents a specific tool or configuration feature.
Cookbooks are kept atomic — one cookbook per tool.
Categorization is done at the role level (see [roles/](../roles/)).

Many simple cross-platform package cookbooks use the `cross_platform_package`
custom resource defined in [`lib/custom_resources.rb`](../lib/custom_resources.rb).
