# TFLint - a pluggable Terraform linter
# https://github.com/terraform-linters/tflint

tflint_version = '0.64.0'

if node[:platform] == 'darwin'
  # Upstream's own tap, not homebrew-core: core carried tflint up to 0.47.0 and
  # has since dropped it, so a bare `tflint` formula no longer resolves.
  package 'terraform-linters/tap/tflint'
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
