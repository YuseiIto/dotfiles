# Install cloc - count lines of code
if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "cloc" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "cloc"
end
