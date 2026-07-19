if %w[ubuntu debian].include?(node[:platform])
  package 'asciinema' do
    user 'root'
  end

  agg_version = '1.5.0'

  github_release_binary 'agg' do
    repo 'asciinema/agg'
    version agg_version
    arm64_name 'agg-aarch64-unknown-linux-gnu'
    x86_64_name 'agg-x86_64-unknown-linux-gnu'
    not_if "agg --version 2>/dev/null | grep -q '#{agg_version}'"
  end
elsif node[:platform] == 'darwin'
  package 'asciinema'
  package 'agg'
else
  unsupported_platform! node[:platform]
end
