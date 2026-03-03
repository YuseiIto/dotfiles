# Install ImageMagick - image manipulation tools
if %w[ubuntu debian].include?(node[:platform])
  package 'imagemagick' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'imagemagick'
end
