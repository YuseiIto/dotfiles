# Install tmux
cross_platform_package 'tmux'

home = ENV['HOME']

# Place .tmux.conf before tpm install so the tmux server can load @plugin options
dotconfig 'tmux'

xdg_tmux_dir = "#{home}/.config/tmux"

execute 'Install tpm' do
  command "git clone https://github.com/tmux-plugins/tpm #{xdg_tmux_dir}/plugins/tpm"
  not_if "test -d #{xdg_tmux_dir}/plugins/tpm"
end

execute 'Install tpm plugins' do
  # install_plugins uses `tmux show-option` to read the @plugin list from the
  # running server. Start a detached server, source the config to ensure
  # @plugin options are loaded, install, then clean up only the session we
  # created (leave any existing server intact for macOS bare metal).
  command <<~EOC
    tmux start-server
    tmux new-session -d -s mitamae_setup 2>/dev/null || true
    tmux source-file #{xdg_tmux_dir}/tmux.conf
    #{xdg_tmux_dir}/plugins/tpm/bin/install_plugins
    tmux kill-session -t mitamae_setup 2>/dev/null || true
  EOC
  not_if "test -d #{xdg_tmux_dir}/plugins/tmux-sensible"
end
