if node[:platform] == 'darwin'
  # The formula installs flatcam-evo's Python deps via pip, including gdal.
  # gdal ships no PyPI wheels (upstream policy), so it must build from source
  # against the Homebrew gdal C library, and that build fails depending on
  # the host's exact gdal/Python/headers state. The fix has to come from
  # upstream — until then, don't sink provisioning over it.
  package 'tomoyanonymous/homebrew-flatcam/flatcam-evo' do
    ignore_failure true
  end
else
  Mitamae.logger.error "unsupported platform #{node[:platform]}: #{__FILE__}:#{__LINE__}"
  exit 1
end
