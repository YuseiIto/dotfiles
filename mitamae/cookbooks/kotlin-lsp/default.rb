# Kotlin LSP - Language server for Kotlin
# https://github.com/Kotlin/kotlin-lsp
# Linux builds are published on the JetBrains CDN as a self-contained
# zip that bundles its own JRE under jre/, so the kotlin-lsp.sh launcher
# needs no system Java.

kotlin_lsp_version = '262.2310.0'

if node[:platform] == 'darwin'
  package 'JetBrains/utils/kotlin-lsp'
elsif %w[ubuntu debian].include?(node[:platform])
  arch = case node[:os_arch]
         when 'arm64' then 'aarch64'
         else 'x64'
         end

  archive = "kotlin-lsp-#{kotlin_lsp_version}-linux-#{arch}.zip"
  url = "https://download-cdn.jetbrains.com/kotlin-lsp/#{kotlin_lsp_version}/#{archive}"

  package 'unzip' do
    user 'root'
  end

  directory '/opt/kotlin-lsp' do
    user 'root'
  end

  # The zip carries FAT permissions (no unix exec bits), so the bundled JRE binaries land non-executable.
  # The launcher self-chmods java at runtime, but that fails for the non-root
  # user the container runs as, so make them executable here (as root) instead.
  execute 'Install kotlin-lsp' do
    command <<~CMD
      curl -fsSL -o /tmp/#{archive} "#{url}" &&
      unzip -o /tmp/#{archive} -d /opt/kotlin-lsp &&
      chmod +x /opt/kotlin-lsp/kotlin-lsp.sh &&
      find /opt/kotlin-lsp/jre -type f \\( -path '*/bin/*' -o -name jspawnhelper \\) -exec chmod a+rx {} + &&
      rm -f /tmp/#{archive}
    CMD
    user 'root'
    not_if 'test -x /opt/kotlin-lsp/jre/bin/java'
  end

  # kotlin-lsp.sh resolves symlinks back to its own directory to locate lib/ and jre/,
  # so a symlink on PATH works without a wrapper.
  link '/usr/local/bin/kotlin-lsp' do
    to '/opt/kotlin-lsp/kotlin-lsp.sh'
    user 'root'
    force true
  end
else
  unsupported_platform! node[:platform]
end
