# NOTE: The cask token is `claude`, not `claude-desktop`; `claude-code` is the
# separate CLI cask installed by the claude-code cookbook.
if node[:platform] == 'darwin'
  brew_cask 'claude'
else
  unsupported_platform! node[:platform]
end
