# Install zsh
if node[:platform] == 'darwin'
  package 'zsh'
elsif %w[ubuntu debian].include?(node[:platform])
  package 'zsh' do
    user 'root'
  end
end

dotfile '.zshrc'
