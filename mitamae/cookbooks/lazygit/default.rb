if node[:platform] == 'darwin'
  package 'lazygit'
elsif %w[ubuntu debian].include?(node[:platform])
  # renovate: datasource=github-releases depName=jesseduffield/lazygit extractVersion=^v(?<version>.+)$
  lazygit_version = '0.66.2'

  github_release_binary 'lazygit' do
    repo 'jesseduffield/lazygit'
    version lazygit_version
    arm64_name "lazygit_#{lazygit_version}_Linux_arm64.tar.gz"
    x86_64_name "lazygit_#{lazygit_version}_Linux_x86_64.tar.gz"
    archive_member 'lazygit'
    # renovate: datasource=github-release-attachments depName=jesseduffield/lazygit
    arm64_sha256 'v0.66.2@79a3161eeb642f0473e23db6341f7baabd4a5933e921a9c1167c5d5c765c41a4'
    # renovate: datasource=github-release-attachments depName=jesseduffield/lazygit
    x86_64_sha256 'v0.66.2@158efc9ddfa1241fab5fb3526bb442c8dc6c4b1904d73213b9e4e93e03c52034'
    not_if "lazygit --version 2>/dev/null | grep -q '#{lazygit_version}'"
  end
else
  unsupported_platform! node[:platform]
end

dotconfig 'lazygit'
