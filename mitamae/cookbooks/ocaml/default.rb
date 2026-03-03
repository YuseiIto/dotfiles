# Install OCaml compiler and package manager
if node[:platform] == "ubuntu" || node[:platform] == "debian"
  package "ocaml" do
    user "root"
  end
  package "opam" do
    user "root"
  end
elsif node[:platform] == "darwin"
  package "ocaml"
end
