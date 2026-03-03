include_recipe '../nodenv'

if node[:platform] == 'darwin'
  package 'typescript-language-server'
elsif %w[ubuntu debian].include?(node[:platform])
  execute 'Install typescript-language-server via npm' do
    command 'npm install -g typescript typescript-language-server'
    not_if 'command -v typescript-language-server'
  end
end
