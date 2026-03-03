# Install ffmpeg - audio/video processing tool
if %w[ubuntu debian].include?(node[:platform])
  package 'ffmpeg' do
    user 'root'
  end
elsif node[:platform] == 'darwin'
  package 'ffmpeg'
end
