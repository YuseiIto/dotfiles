# Install ccls - C/C++/ObjC language server.
#
# The `ccls` apt package was dropped from Ubuntu starting with 26.04
# (resolute); on those releases the C/C++ LSP Neovim actually enables is
# clangd, installed via the `llvm` cookbook. Install ccls from apt only
# when an installation candidate exists so the provisioning run stays green
# on newer Debian-family releases instead of aborting on a missing package.
# macOS keeps ccls via Homebrew, which still ships it.
case node[:platform]
when 'ubuntu', 'debian'
  package 'ccls' do
    user 'root'
    # apt-cache prints "Candidate: (none)" for a known-but-uninstallable
    # package and nothing at all for an unknown one; install only when a
    # real candidate version is offered.
    only_if "apt-cache policy ccls 2>/dev/null | grep 'Candidate:' | grep -qv '(none)'"
  end
when 'darwin'
  package 'ccls'
else
  unsupported_platform! node[:platform]
end
