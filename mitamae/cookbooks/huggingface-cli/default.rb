if node[:platform] == 'darwin'
  package 'huggingface-cli'
elsif node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  execute 'Install huggingface-cli via official installer' do
    command 'uv tool install hf'
    not_if 'command -v hf'
  end
end
