# Install OCaml compiler and package manager

disable_sandboxing = if node[:is_container]
                       '--disable-sandboxing'
                     else
                       ''
                     end

cross_platform_package 'ocaml'
cross_platform_package 'opam'

# NOTE: `--bare` defers switch creation so the compiler is solved together with
# ocaml-lsp-server below. Letting `opam init` pick the newest compiler forces an
# in-switch downgrade whenever ocaml-lsp-server lags behind, and that rebuild
# fails (e.g. topkg / ocaml-index on OCaml 5.5.2 -> 5.4.1).
execute 'Init opam' do
  command "opam init --bare --auto-setup --quiet #{disable_sandboxing}"
  not_if "test -d #{ENV['HOME']}/.opam"
end

execute 'Create default opam switch' do
  command 'opam switch create default --empty'
  not_if 'opam switch list --short | grep -qx default'
end

execute 'Install ocaml-lsp-server via opam' do
  # Restore the unpinned `ocaml` invariant that `opam init` would have set, as
  # the empty switch starts with none.
  command 'opam install -y --switch default ocaml ocaml-lsp-server && ' \
          'opam switch set-invariant --switch default ocaml'
  # opam installs into the switch's bin (~/.opam/default/bin) which is not on
  # PATH during the mitamae run, so `command -v ocamllsp` would never
  # short-circuit. Test the installed binary directly so the install only
  # runs once.
  not_if "test -x #{ENV['HOME']}/.opam/default/bin/ocamllsp"
end
