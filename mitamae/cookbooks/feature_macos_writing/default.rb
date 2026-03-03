# Writing and documentation tools
if node[:platform] == 'darwin'
  casks = %w[
    obsidian
    drawio
    mactex-no-gui
  ]

  casks.each do |cask|
    execute "install #{cask} via homebrew cask" do
      command "brew install --cask #{cask}"
      not_if "brew list --cask #{cask}"
    end
  end
end
