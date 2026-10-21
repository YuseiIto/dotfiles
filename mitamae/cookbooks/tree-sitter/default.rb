# renovate: datasource=github-releases depName=tree-sitter/tree-sitter extractVersion=^v(?<version>.+)$
tree_sitter_version = '0.27.1'

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
    arm64_sha256 'v0.27.1@404be5d54a4955571c4067c21d4699660eab3a534cefb0659341b207f7139ec5'
    # renovate: datasource=github-release-attachments depName=tree-sitter/tree-sitter
    x86_64_sha256 'v0.27.1@d01042f94ba3d6827ddc9788e235f75d8366431be42bdf90ade534d960c98b7d'
    not_if "tree-sitter --version 2>/dev/null | grep -q '#{tree_sitter_version}'"
  end
else
  unsupported_platform! node[:platform]
end
