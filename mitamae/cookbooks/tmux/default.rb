if %w[ubuntu debian].include?(node[:platform])
  package 'tmux' do
    user 'root'
  end
else
  # macOS, Arch Linux
  package 'tmux'
end

dotfile '.tmux.conf' do
  cookbook_dir File.dirname(__FILE__)
end
