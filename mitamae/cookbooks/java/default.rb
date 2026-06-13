if node[:platform] == 'darwin'
  package 'temurin'
elsif %w[ubuntu debian].include?(node[:platform])
  include_recipe '../corretto21'
else
  unsupported_platform! node[:platform]
end
