if %w[ubuntu debian].include?(node[:platform])
  package 'binutils' do
    user 'root'
  end
else
  # macOS, Arch Linux
  package 'binutils'
end
