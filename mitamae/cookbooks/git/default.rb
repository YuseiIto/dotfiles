if %w[ubuntu debian].include?(node[:platform])
  package 'git' do
    user 'root'
  end
else
  # macOS, Arch Linux
  package 'git'
end

dotconfig 'git'
