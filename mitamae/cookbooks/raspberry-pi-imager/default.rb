# Raspberry Pi Imager - utility to write OS images to SD cards / USB drives.
# macOS: Homebrew Cask `raspberry-pi-imager`.
# Debian/Ubuntu: APT package `rpi-imager`.
cross_platform_package 'raspberry-pi-imager' do
  debian_name 'rpi-imager'
  darwin_cask true
end
