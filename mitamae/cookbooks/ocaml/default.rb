# Install OCaml compiler and package manager

disable_sandboxing = if node[:is_container]
                       '--disable-sandboxing'
                     else
                       ''
                     end

cross_platform_package 'ocaml'
cross_platform_package 'opam'

execute 'Init opam' do
  command "opam init --auto-setup --quiet #{disable_sandboxing}"
  not_if "test -d #{ENV['HOME']}/.opam"
end

execute 'Install ocaml-lsp-server via opam' do
  command 'opam install -y ocaml-lsp-server'
  # opam installs into the switch's bin (~/.opam/default/bin) which is not on
  # PATH during the mitamae run, so `command -v ocamllsp` would never
  # short-circuit. Test the installed binary directly so the install only
  # runs once.
  not_if "test -x #{ENV['HOME']}/.opam/default/bin/ocamllsp"
end
