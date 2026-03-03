if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "binutils" do
    user "root"
  end
else
  # macOS, Arch Linux
  package "binutils"
end
