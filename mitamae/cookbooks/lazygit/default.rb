if node[:platform] == 'darwin'
  package 'lazygit'
elsif %w[ubuntu debian].include?(node[:platform])
  # renovate: datasource=github-releases depName=jesseduffield/lazygit extractVersion=^v(?<version>.+)$
  lazygit_version = '0.59.0'

  github_release_binary 'lazygit' do
    repo 'jesseduffield/lazygit'
    version lazygit_version
    arm64_name "lazygit_#{lazygit_version}_Linux_arm64.tar.gz"
    x86_64_name "lazygit_#{lazygit_version}_Linux_x86_64.tar.gz"
    archive_member 'lazygit'
    # renovate: datasource=github-release-attachments depName=jesseduffield/lazygit
    arm64_sha256 'v0.59.0@a334a6c125169f21942f1a8b02043932575547a6250a1a734d62111efd92aa8f'
    # renovate: datasource=github-release-attachments depName=jesseduffield/lazygit
    x86_64_sha256 'v0.59.0@264283f40a40c899d702a338b20622f690221f753f03bac827c1f34e91f516c2'
    not_if "lazygit --version 2>/dev/null | grep -q '#{lazygit_version}'"
  end
else
  unsupported_platform! node[:platform]
end

dotconfig 'lazygit'
