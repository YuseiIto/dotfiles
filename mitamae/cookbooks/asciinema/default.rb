if ['ubuntu', 'debian'].include?(node[:platform])
  package 'asciinema' do
    user 'root'
  end

  agg_version = '1.5.0'

  execute 'Install agg (asciinema gif generator)' do
    command <<~EOC
      arch=$(uname -m)
      case "$arch" in
        aarch64|arm64) arch="aarch64" ;;
        x86_64|amd64) arch="x86_64" ;;
      esac
      curl -fsSL -o /usr/local/bin/agg "https://github.com/asciinema/agg/releases/download/v#{agg_version}/agg-${arch}-unknown-linux-gnu"
      chmod +x /usr/local/bin/agg
    EOC
    user 'root'
    not_if "agg --version 2>/dev/null | grep -q '#{agg_version}'"
  end
elsif node[:platform] == 'darwin'
  package 'asciinema'
  package 'agg'
end
