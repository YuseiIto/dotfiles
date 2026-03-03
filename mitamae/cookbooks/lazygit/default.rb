if node[:platform] == "darwin"
  package "lazygit"
elsif node[:platform] == "ubuntu" || node[:platform] == "debian"
  lazygit_version = "0.59.0"

  execute "Install lazygit" do
    command <<~EOC
      arch=$(uname -m)
      case "$arch" in
        aarch64|arm64) arch="arm64" ;;
        x86_64|amd64) arch="x86_64" ;;
      esac
      lazygit_archive="lazygit_#{lazygit_version}_Linux_${arch}.tar.gz"
      curl -fsSLO "https://github.com/jesseduffield/lazygit/releases/download/v#{lazygit_version}/${lazygit_archive}"
      tar xzf "${lazygit_archive}" lazygit
      install lazygit /usr/local/bin/lazygit
      rm -f lazygit "${lazygit_archive}"
    EOC
    user "root"
    not_if "lazygit --version 2>/dev/null | grep -q '#{lazygit_version}'"
  end
end
