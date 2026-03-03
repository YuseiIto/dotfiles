# Install OCaml compiler and package manager
if %w[ubuntu debian].include?(node[:platform])
  package 'ocaml' do
    user 'root'
  end
  package 'opam' do
    user 'root'
  end
  execute 'Install ocaml-lsp-server via opam' do
    command 'opam install -y ocaml-lsp-server'
    not_if 'command -v ocamllsp'
  end
elsif node[:platform] == 'darwin'
  package 'ocaml'
  package 'ocaml-lsp'
end
