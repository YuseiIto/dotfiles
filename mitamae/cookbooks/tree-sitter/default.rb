# renovate: datasource=github-releases depName=tree-sitter/tree-sitter extractVersion=^v(?<version>.+)$
tree_sitter_version = '0.27.2'

case node[:platform]
when 'darwin'
  package 'tree-sitter-cli'
when 'ubuntu', 'debian'
  github_release_binary 'tree-sitter' do
    repo 'tree-sitter/tree-sitter'
    version tree_sitter_version
    arm64_name 'tree-sitter-linux-arm64.gz'
    x86_64_name 'tree-sitter-linux-x64.gz'
    # renovate: datasource=github-release-attachments depName=tree-sitter/tree-sitter
    arm64_sha256 'v0.27.2@34fcc5c4fa7bdd2058a2a45a03b6eb9a49b03a93b6d52ec750f99b1516d98d33'
    # renovate: datasource=github-release-attachments depName=tree-sitter/tree-sitter
    x86_64_sha256 'v0.27.2@7ed56d152c52437397b9fcaa43cf341f49933cecc1ca291843f0d347c6e2cb3a'
    not_if "tree-sitter --version 2>/dev/null | grep -q '#{tree_sitter_version}'"
  end
else
  unsupported_platform! node[:platform]
end
