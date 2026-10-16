# Cookbook-local: symlink a file or directory under ~/.claude
define :claude_dotfile, source: nil, cookbook_dir: nil do
  source_file = params[:source] || params[:name]
  dir = params[:cookbook_dir]
  claude_dir = File.join(ENV['HOME'], '.claude')

  directory claude_dir

  link File.join(claude_dir, params[:name]) do
    to File.join(dir, 'files', source_file)
    force true
  end
end

# Use "latest" to always install the latest version of claude-code to get the latest models and features.
# This may degrade stability, but it's the nature of the rapidly evolving AI ecosystem.
if node[:platform] == 'darwin'
  brew_cask 'claude-code@latest'
elsif %w[ubuntu debian].include?(node[:platform])
  # NOTE: The claude-security plugin runs its helpers with python3 (>= 3.9).
  # Minimal Debian/Ubuntu images ship without it; macOS provides /usr/bin/python3.
  package 'python3'

  execute 'install claude-code via official installer' do
    command 'curl -fsSL https://claude.ai/install.sh | bash -s latest'
    not_if 'command -v claude'
  end
else
  unsupported_platform! node[:platform]
end

cookbook_dir = File.dirname(__FILE__)
# Shared with files/claude-dotfiles-link so both link the same entries.
# NOTE: mitamae runs on mruby, which lacks File.readlines.
entries = File.read(File.join(cookbook_dir, 'files', 'dotfile-entries')).split("\n").reject(&:empty?)

entries.each do |entry|
  claude_dotfile entry do
    cookbook_dir cookbook_dir
  end
end

bin_dir = "#{ENV['HOME']}/.local/bin"
directory bin_dir

link "#{bin_dir}/claude-dotfiles-link" do
  to File.join(cookbook_dir, 'files', 'claude-dotfiles-link')
  force true
end
