# Kotlin LSP - Language server for Kotlin
# https://github.com/Kotlin/kotlin-lsp
# Linux builds are published by JetBrains as a self-contained tarball that
# bundles its own runtime, so the kotlin-lsp.sh launcher needs no system Java.

# renovate: datasource=github-releases depName=Kotlin/kotlin-lsp extractVersion=^kotlin-lsp/v(?<version>.+)$
kotlin_lsp_version = '263.6379.0'

if node[:platform] == 'darwin'
  # JetBrains publishes this through their own tap as a formula, but
  # homebrew-cask carries the same build at the same version, so use the
  # official tap and skip the third-party one.
  brew_cask 'kotlin-lsp'

  # HACK: The build is not notarized, so Gatekeeper blocks it while quarantined.
  # Clear the attribute only after checking every Mach-O is JetBrains-signed.
  # Ref: https://github.com/Kotlin/kotlin-lsp/issues/194
  execute 'Clear Gatekeeper quarantine on kotlin-lsp' do
    command <<~CMD
      set -eu
      dir="$(brew --caskroom)/kotlin-lsp"
      find "$dir" -type f -exec sh -c '
        for f; do
          case "$(file -b "$f")" in
            Mach-O*) codesign --verify --strict -R "$0" "$f" || exit 1 ;;
          esac
        done
      ' '=anchor apple generic and certificate leaf[subject.OU] = "2ZEFAR8TH3"' {} +
      # -s: symlinks carry their own attribute
      xattr -drs com.apple.quarantine "$dir"
    CMD
    only_if 'find "$(brew --caskroom)/kotlin-lsp" -xattrname com.apple.quarantine -print -quit | grep -q .'
  end
elsif %w[ubuntu debian].include?(node[:platform])
  # NOTE: JetBrains removes older builds from the CDN, so a stale pin breaks
  # provisioning outright rather than just lagging behind.
  # NOTE: No digest pin, unlike github_release_binary downloads: the asset is
  # on JetBrains' CDN, which Renovate's github-release-attachments datasource
  # cannot read, so a pin would go stale on every version bump. The `.sha256`
  # file JetBrains publishes next to the archive is not checked either: it
  # comes from the same host, so it would catch corruption but not tampering.
  arch_suffix = node[:os_arch] == 'arm64' ? '-aarch64' : ''

  archive = "kotlin-server-#{kotlin_lsp_version}#{arch_suffix}.tar.gz"
  url = "https://download.jetbrains.com/language-server/kotlin-server/#{kotlin_lsp_version}/#{archive}"
  # The tarball unpacks into kotlin-server-<version>/, so a versioned install
  # dir lets the guard below pick up version bumps.
  install_dir = "/opt/kotlin-server-#{kotlin_lsp_version}"

  execute 'Install kotlin-lsp' do
    command <<~CMD
      set -eu
      work_dir="$(mktemp -d)"
      # Staged on the same filesystem so the final mv is a rename: an
      # interrupted extract never leaves a partial tree the guard accepts.
      stage_dir="$(mktemp -d /opt/.kotlin-server.XXXXXX)"
      trap 'rm -rf "$work_dir" "$stage_dir"' EXIT
      curl -fsSL -o "$work_dir/#{archive}" "#{url}"
      tar -xzf "$work_dir/#{archive}" -C "$stage_dir"
      rm -rf "#{install_dir}"
      mv "$stage_dir/kotlin-server-#{kotlin_lsp_version}" "#{install_dir}"
    CMD
    user 'root'
    not_if "test -x #{install_dir}/kotlin-lsp.sh"
  end

  # Same layout and link target as the homebrew-cask build, which also exposes
  # kotlin-lsp.sh through a plain symlink.
  link '/usr/local/bin/kotlin-lsp' do
    to "#{install_dir}/kotlin-lsp.sh"
    user 'root'
    force true
  end
else
  unsupported_platform! node[:platform]
end
