if %w[ubuntu debian].include?(node[:platform])
  package 'tmux' do
    user 'root'
  end
else
  # macOS, Arch Linux
  package 'tmux'
end

# Configure tmux
cookbook_dir = File.expand_path('.', File.dirname(__FILE__))
home = ENV['HOME']

# Symlink ".tmux.conf".
link "#{home}/.tmux.conf" do
  to File.join(cookbook_dir, 'files', '.tmux.conf')
  force true
end
