# Install CMake - cross-platform build system
if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "cmake" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "cmake"
end
