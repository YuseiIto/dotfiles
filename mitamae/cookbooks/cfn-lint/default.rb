include_recipe '../uv'

if node[:platform] == 'darwin'
  package 'cfn-lint'
elsif ['ubuntu', 'debian'].include?(node[:platform])
  execute 'Install cfn-lint via uv' do
    command 'uv tool install cfn-lint'
    not_if 'command -v cfn-lint'
  end
end
