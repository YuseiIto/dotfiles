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
    not_if "lazygit --version 2>/dev/null | grep -q '#{lazygit_version}'"
  end
else
  unsupported_platform! node[:platform]
end

dotconfig 'lazygit'
