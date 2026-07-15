# Android Studio: the official IDE for Android development
# https://developer.android.com/studio

if node[:platform] == 'darwin'
  brew_cask 'android-studio'
elsif %w[ubuntu debian].include?(node[:platform])
  package 'snapd' do
    user 'root'
  end

  execute 'Install Android Studio via snap' do
    command 'snap install android-studio --classic'
    user 'root'
    not_if 'snap list | grep -q android-studio'
  end
else
  unsupported_platform! node[:platform]
end
