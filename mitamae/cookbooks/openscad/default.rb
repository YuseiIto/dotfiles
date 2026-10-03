# NOTE: Homebrew disabled the stable openscad cask (2021.01, the latest
# upstream release) on 2026-09-01 because the app is not notarized. The
# snapshot cask is notarized and is what upstream recommends for current
# features. It conflicts with the stable cask, so machines that still have it
# need `brew uninstall --cask openscad` once.
cross_platform_package 'openscad' do
  darwin_cask true
  darwin_name 'openscad@snapshot'
end
