if node[:platform] == 'darwin'
  # NOTE: Homebrew disabled the alacritty cask on 2026-09-01 because the
  # upstream app is not notarized (fails_gatekeeper_check), so install the
  # release DMG directly. curl sets no quarantine attribute and the bundle is
  # ad-hoc signed, so Gatekeeper lets it run.
  # Upstream publishes no checksum file; the digest is the one GitHub reports
  # for the release asset. Renovate bumps both values together, so keep them
  # on adjacent lines.
  alacritty_tag = 'v0.17.0'
  alacritty_dmg_sha256 = 'ad8d7de35fb38e43184776cac6dfee05ca325caa0b6639a06a55e54e4b026620'

  app_path = '/Applications/Alacritty.app'
  dmg_url = "https://github.com/alacritty/alacritty/releases/download/#{alacritty_tag}/Alacritty-#{alacritty_tag}.dmg"

  staged_path = "#{app_path}.partial"
  old_path = "#{app_path}.old"

  # Stage next to app_path and swap with renames so an interrupted copy never
  # leaves a partial bundle that the version check would accept, and a running
  # Alacritty (likely the terminal running mitamae) never loses its bundle.
  # The mount point lives outside work_dir so cleanup cannot recurse into a
  # volume that failed to detach. Cleanup failures must not fail the install.
  execute "Install Alacritty.app #{alacritty_tag}" do
    command <<~EOC
      set -eu
      work_dir="$(mktemp -d)"
      mount_dir="$(mktemp -d)"
      cleanup() {
        hdiutil detach -quiet -force "$mount_dir" 2>/dev/null || true
        rmdir "$mount_dir" 2>/dev/null || true
        rm -rf "$work_dir" "#{staged_path}" || true
        if [ ! -e "#{app_path}" ] && [ -e "#{old_path}" ]; then
          mv "#{old_path}" "#{app_path}" || true
        fi
        rm -rf "#{old_path}" || true
      }
      trap cleanup EXIT
      # A killed earlier run skips its trap; ditto would merge into leftovers.
      rm -rf "#{staged_path}" "#{old_path}"
      curl -fsSL -o "$work_dir/Alacritty.dmg" "#{dmg_url}"
      echo "#{alacritty_dmg_sha256}  $work_dir/Alacritty.dmg" | shasum -a 256 -c -
      hdiutil attach -quiet -nobrowse -readonly -mountpoint "$mount_dir" "$work_dir/Alacritty.dmg"
      ditto "$mount_dir/Alacritty.app" "#{staged_path}"
      if [ -e "#{app_path}" ]; then mv "#{app_path}" "#{old_path}"; fi
      mv "#{staged_path}" "#{app_path}"
    EOC
    # PlistBuddy reads the file directly; `defaults read` goes through
    # cfprefsd, which may serve a cached version after the bundle is swapped.
    not_if "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' #{app_path}/Contents/Info.plist 2>/dev/null " \
           "| grep -qx '#{alacritty_tag.delete_prefix('v')}'"
  end

  # The config pins TERM=alacritty, but macOS's ncurses database lacks that
  # entry. Expose the terminfo compiled into the bundle, as the cask used to.
  terminfo_dir = File.join(ENV['HOME'], '.terminfo', '61')
  directory terminfo_dir

  %w[alacritty alacritty-direct].each do |entry|
    link File.join(terminfo_dir, entry) do
      to "#{app_path}/Contents/Resources/61/#{entry}"
      force true
    end
  end
elsif %w[ubuntu debian].include?(node[:platform])
  package 'snapd' do
    user 'root'
  end

  execute 'Install Alacritty via snap' do
    command 'snap install alacritty --classic'
    user 'root'
    not_if 'snap list | grep -q alacritty'
  end
else
  unsupported_platform! node[:platform]
end

dotconfig 'alacritty'
