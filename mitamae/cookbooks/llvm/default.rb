cross_platform_package 'llvm' do
  # Debian/Ubuntu ship clangd in a standalone `clangd` package.
  debian_name 'clangd'
end
