if %w[ubuntu debian].include?(node[:platform])
  package 'asciinema' do
    user 'root'
  end

  # renovate: datasource=github-releases depName=asciinema/agg extractVersion=^v(?<version>.+)$
  agg_version = '1.9.0'

  github_release_binary 'agg' do
    repo 'asciinema/agg'
    version agg_version
    arm64_name 'agg-aarch64-unknown-linux-gnu'
    x86_64_name 'agg-x86_64-unknown-linux-gnu'
    # renovate: datasource=github-release-attachments depName=asciinema/agg
    arm64_sha256 'v1.9.0@2b4be407b97e00e1c313a41d154ced8fa3d02c560c8f47a0db4950a2576444c9'
    # renovate: datasource=github-release-attachments depName=asciinema/agg
    x86_64_sha256 'v1.9.0@f111e315cd71056b116302342553dd765b7297579ed511f111d0cedb442aeda6'
    not_if "agg --version 2>/dev/null | grep -q '#{agg_version}'"
  end
elsif node[:platform] == 'darwin'
  package 'asciinema'
  package 'agg'
else
  unsupported_platform! node[:platform]
end
