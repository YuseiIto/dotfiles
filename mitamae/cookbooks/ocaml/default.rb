# Install OCaml compiler and package manager

disable_sandboxing = if node[:is_container]
                       '--disable-sandboxing'
                     else
                       ''
                     end

if %w[ubuntu debian].include?(node[:platform])
  package 'ocaml' do
    user 'root'
  end
  package 'opam' do
    user 'root'
  end

  execute 'Init opam' do
    command "opam init --auto-setup --quiet #{disable_sandboxing}"
    not_if 'opam config env'
  end

  execute 'Install ocaml-lsp-server via opam' do
    command 'opam install -y ocaml-lsp-server'
    not_if 'command -v ocamllsp'
  end

elsif node[:platform] == 'darwin'
  package 'ocaml'

  execute 'Init opam' do
    command "opam init --auto-setup --quiet #{disable_sandboxing}"
    not_if 'opam config env'
  end

  package 'ocaml-lsp'
end
