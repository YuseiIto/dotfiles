# Install OCaml compiler and package manager
if ['ubuntu', 'debian'].include?(node[:platform])
  package 'ocaml' do
    user 'root'
  end
  package 'opam' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'ocaml'
end
