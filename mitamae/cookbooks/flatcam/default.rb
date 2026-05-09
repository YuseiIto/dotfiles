if node[:platform] == 'darwin'
  # The formula installs flatcam-evo's Python deps via pip, including gdal.
  # gdal ships no PyPI wheels, so it must build from source against the
  # Homebrew gdal C library, and that build fails depending on the host's
  # gdal/Python/headers state. The fix has to come from upstream — until
  # then, don't sink provisioning over it.
  #
  # mitamae's `package` resource has no `ignore_failure`, so shell out via
  # `execute` and swallow a non-zero brew exit with `|| true`.
  execute 'Install flatcam-evo (best effort)' do
    command 'brew install tomoyanonymous/homebrew-flatcam/flatcam-evo || true'
    not_if 'brew list --formula tomoyanonymous/homebrew-flatcam/flatcam-evo >/dev/null 2>&1'
  end
else
  Mitamae.logger.error "unsupported platform #{node[:platform]}: #{__FILE__}:#{__LINE__}"
  exit 1
end
