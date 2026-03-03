if %w[ubuntu debian].include?(node[:platform])
  package 'iverilog' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'icarus-verilog'
end
