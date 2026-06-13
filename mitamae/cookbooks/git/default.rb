if %w[ubuntu debian].include?(node[:platform])
  package 'git' do
    user 'root'
  end
elsif %w[darwin arch].include?(node[:platform])
  package 'git'
else
  unsupported_platform! node[:platform]
end

dotconfig 'git'
