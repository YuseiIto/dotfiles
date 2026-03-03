# Install ImageMagick - image manipulation tools
if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "imagemagick" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "imagemagick"
end
