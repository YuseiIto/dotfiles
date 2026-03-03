if node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  package 'iverilog' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'icarus-verilog'
end
