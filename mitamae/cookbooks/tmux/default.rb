if %w[ubuntu debian].include?(node[:platform])
  package 'tmux' do
    user 'root'
  end
else
  # macOS, Arch Linux
  package 'tmux'
end

home = ENV['HOME']

execute 'Install tpm' do
  command "git clone https://github.com/tmux-plugins/tpm #{home}/.tmux/plugins/tpm"
  not_if "test -d #{home}/.tmux/plugins/tpm"
end

execute 'Install tpm plugins' do
  command "#{home}/.tmux/plugins/tpm/bin/install_plugins"
  not_if "test -d #{home}/.tmux/plugins/tmux-sensible"
end

dotfile '.tmux.conf' do
  cookbook_dir File.dirname(__FILE__)
end
