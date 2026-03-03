# Install ffmpeg - audio/video processing tool
if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "ffmpeg" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "ffmpeg"
end
