if %w[ubuntu debian].include?(node[:platform])
  package 'tmux' do
    user 'root'
  end
else
  # macOS, Arch Linux
  package 'tmux'
end

home = ENV['HOME']

# Place .tmux.conf before tpm install so the tmux server can load @plugin options
dotfile '.tmux.conf' do
  cookbook_dir File.dirname(__FILE__)
end

execute 'Install tpm' do
  command "git clone https://github.com/tmux-plugins/tpm #{home}/.tmux/plugins/tpm"
  not_if "test -d #{home}/.tmux/plugins/tpm"
end

execute 'Install tpm plugins' do
  # install_plugins uses `tmux show-option` to read the @plugin list from the
  # running server. Start a detached server, source the config to ensure
  # @plugin options are loaded, install, then clean up only the session we
  # created (leave any existing server intact for macOS bare metal).
  command <<~EOC
    tmux start-server
    tmux new-session -d -s mitamae_setup 2>/dev/null || true
    tmux source-file #{home}/.tmux.conf
    #{home}/.tmux/plugins/tpm/bin/install_plugins
    tmux kill-session -t mitamae_setup 2>/dev/null || true
  EOC
  not_if "test -d #{home}/.tmux/plugins/tmux-sensible"
end
