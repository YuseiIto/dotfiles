

normalized_arch = case node[:kernel][:machine]
                  when "aarch64", "arm64" then "arm64"
                  else "x86_64"
                  end

# Feature Configuration
node.reverse_merge!(
  variant: "pine",
  os_arch: normalized_arch,
  features: {
    cli_essentials: true,
  }
)


# Load Recipes
include_recipe "../../cookbooks/neovim"
