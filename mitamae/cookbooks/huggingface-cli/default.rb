if node[:platform] == 'darwin'
  package 'huggingface-cli'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'Install huggingface-cli via official installer' do
    command 'uv tool install hf'
    not_if 'command -v hf'
  end
end
