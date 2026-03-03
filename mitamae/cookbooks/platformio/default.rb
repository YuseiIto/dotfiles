if node[:platform] == 'darwin'
  package 'platformio'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'Install PlatformIO via official installer' do
    command 'uv tool install platformio'
    not_if 'command -v pio || test -f ~/.platformio/penv/bin/pio'
  end
end
