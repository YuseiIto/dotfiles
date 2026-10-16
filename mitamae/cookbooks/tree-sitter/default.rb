# renovate: datasource=github-releases depName=tree-sitter/tree-sitter extractVersion=^v(?<version>.+)$
tree_sitter_version = '0.25.10'

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
    arm64_sha256 'v0.25.10@07fbff8ae0eeb0d3e496e14fc1a30dcc730cc2c97d70e601e5357f2e51958af5'
    # renovate: datasource=github-release-attachments depName=tree-sitter/tree-sitter
    x86_64_sha256 'v0.25.10@8283ddba69253c698f6e987ba0e2f9285e079c8db4d36ebe1394b5bb3a0ebdfd'
    not_if "tree-sitter --version 2>/dev/null | grep -q '#{tree_sitter_version}'"
  end
else
  unsupported_platform! node[:platform]
end
