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
    not_if "tree-sitter --version 2>/dev/null | grep -q '#{tree_sitter_version}'"
  end
else
  unsupported_platform! node[:platform]
end
