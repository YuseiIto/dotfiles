if node[:platform] == 'darwin'
  package 'opencode'
elsif %w[ubuntu debian].include?(node[:platform])
  include_recipe '../nodenv'
  execute 'Install opencode' do
    command 'npm install -g opencode-ai'
    not_if 'command -v opencode'
  end
end
