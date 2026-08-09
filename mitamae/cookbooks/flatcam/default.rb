if node[:platform] == 'darwin'
  # The formula installs flatcam-evo's Python deps via pip, including gdal.
  # gdal ships no PyPI wheels, so it must build from source against the
  # Homebrew gdal C library, and that build fails depending on the host's
  # gdal/Python/headers state. The fix has to come from upstream — until
  # then, don't sink provisioning over it.
  #
  # mitamae's `package` resource has no `ignore_failure`, so shell out via
  # `execute` and swallow a non-zero brew exit with `|| true`. The execute name
  # follows the convention scripts/audit-packages.sh scrapes, so the package
  # audit can still see this as declared; it uses brew's canonical tap spelling
  # (no `homebrew-` prefix) so the name matches what brew reports.
  execute 'install tomoyanonymous/flatcam/flatcam-evo via homebrew formula' do
    command 'brew install tomoyanonymous/flatcam/flatcam-evo || true'
    not_if 'brew list --formula tomoyanonymous/flatcam/flatcam-evo >/dev/null 2>&1'
  end
else
  unsupported_platform! node[:platform]
end
