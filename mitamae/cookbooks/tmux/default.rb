if %w[ubuntu debian].include?(node[:platform])
  package 'tmux' do
    user 'root'
  end
else
  # macOS, Arch Linux
  package 'tmux'
end

dotfile '.tmux.conf'
