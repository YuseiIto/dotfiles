if %w[ubuntu debian].include?(node[:platform])
  package 'asciinema' do
    user 'root'
  end

  # renovate: datasource=github-releases depName=asciinema/agg extractVersion=^v(?<version>.+)$
  agg_version = '1.5.0'

  github_release_binary 'agg' do
    repo 'asciinema/agg'
    version agg_version
    arm64_name 'agg-aarch64-unknown-linux-gnu'
    x86_64_name 'agg-x86_64-unknown-linux-gnu'
    # renovate: datasource=github-release-attachments depName=asciinema/agg
    arm64_sha256 'v1.5.0@7553cfc66db649ef3d3dc20313bba00dedac88c60153d2805db937067dabe3d1'
    # renovate: datasource=github-release-attachments depName=asciinema/agg
    x86_64_sha256 'v1.5.0@59673469d625df6f55c72159c84ffbb7af1348ac379d0e79db43f4b80fb986a3'
    not_if "agg --version 2>/dev/null | grep -q '#{agg_version}'"
  end
elsif node[:platform] == 'darwin'
  package 'asciinema'
  package 'agg'
else
  unsupported_platform! node[:platform]
end
