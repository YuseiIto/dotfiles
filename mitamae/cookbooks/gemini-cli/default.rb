if node[:platform] == 'darwin'
  package 'gemini-cli'
elsif %w[ubuntu debian].include?(node[:platform])
  npm_global_package '@google/gemini-cli' do
    bin_name 'gemini'
  end
else
  unsupported_platform! node[:platform]
end
