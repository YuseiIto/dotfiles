# TFLint - a pluggable Terraform linter
# https://github.com/terraform-linters/tflint

tflint_version = '0.64.0'

if node[:platform] == 'darwin'
  # Upstream's own tap, not homebrew-core: tflint embeds Terraform fork code
  # that is BUSL-1.1, so core removed the formula in 2026-05. What the tap
  # publishes is a *cask* (the release archive), not a formula.
  #
  # Formulae get tapped on demand when named in full; casks do not, so tap
  # first. `brew install` then needs the fully qualified name because Homebrew
  # will not load an untrusted third-party tap from a bare token.
  execute 'brew tap terraform-linters/tap' do
    not_if 'brew tap | grep -qx terraform-linters/tap'
  end

  brew_cask 'tflint' do
    source 'terraform-linters/tap/tflint'
  end
elsif %w[ubuntu debian].include?(node[:platform])
  # Upstream publishes no apt repository, and its install_linux.sh is scheduled
  # for removal on Sep 1, 2026, so pin the release asset directly.
  github_release_binary 'tflint' do
    repo 'terraform-linters/tflint'
    version tflint_version
    arm64_name 'tflint_linux_arm64.zip'
    x86_64_name 'tflint_linux_amd64.zip'
    not_if "tflint --version 2>/dev/null | grep -q '#{tflint_version}'"
  end
else
  unsupported_platform! node[:platform]
end
