if node[:platform] == 'darwin'
  package 'biome'
elsif %w[ubuntu debian].include?(node[:platform])
  include_recipe '../nodenv'
  execute 'Install biome via npm' do
    command 'npm install -g @biomejs/biome'
    not_if 'command -v biome'
  end
end
