# Install pandoc - universal document converter
if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "pandoc" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "pandoc"
end
