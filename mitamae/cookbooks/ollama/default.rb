if node[:platform] == 'darwin'
  package 'ollama'
elsif node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  include_recipe '../zstd' # ollama installer depends on zstd
  execute 'Install ollama via official installer' do
    command 'curl -fsSL https://ollama.com/install.sh | sh'
    user 'root'
    not_if 'command -v ollama'
  end
end
