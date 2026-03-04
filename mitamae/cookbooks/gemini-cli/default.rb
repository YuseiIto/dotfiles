if node[:platform] == 'darwin'
  package 'gemini-cli'
elsif %w[ubuntu debian].include?(node[:platform])
  npm_global_package '@google/gemini-cli' do
    bin_name 'gemini'
  end
end
