# devcontainer CLI is distributed only as an npm package; no maintained
# Homebrew or apt formula exists, so install via npm on every platform.
# Ref: https://github.com/devcontainers/cli
npm_global_package '@devcontainers/cli' do
  bin_name 'devcontainer'
end
