if node[:platform] == 'darwin'
  package 'gemini-cli'
elsif %w[ubuntu debian].include?(node[:platform])
  npm_global_package '@google/gemini-cli', bin_name: 'gemini'
end
