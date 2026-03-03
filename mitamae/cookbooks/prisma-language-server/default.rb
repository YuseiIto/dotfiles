include_recipe '../nodenv'

execute 'Install prisma-language-server via npm' do
  command 'npm install -g @prisma/language-server'
  not_if 'command -v prisma-language-server'
end
