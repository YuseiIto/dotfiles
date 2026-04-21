# Kotlin LSP - Language server for Kotlin
# https://github.com/Kotlin/kotlin-lsp
# Requires Java 17+ (provided by corretto21 cookbook)

kotlin_lsp_version = '262.2310.0'

if node[:platform] == 'darwin'
  package 'JetBrains/utils/kotlin-lsp'
elsif %w[ubuntu debian].include?(node[:platform])
  arch = case node[:os_arch]
         when 'arm64' then 'aarch64'
         else 'x64'
         end

  archive = "kotlin-lsp-#{kotlin_lsp_version}-linux-#{arch}.zip"
  url = "https://github.com/Kotlin/kotlin-lsp/releases/download/v#{kotlin_lsp_version}/#{archive}"

  directory '/opt/kotlin-lsp' do
    user 'root'
  end

  execute 'Install kotlin-lsp' do
    command <<~EOC
      curl -fsSL -o /tmp/#{archive} #{url}
      unzip -o /tmp/#{archive} -d /opt/kotlin-lsp
      chmod +x /opt/kotlin-lsp/bin/kotlin-lsp
      rm -f /tmp/#{archive}
    EOC
    user 'root'
    not_if "kotlin-lsp --version 2>/dev/null | grep -q '#{kotlin_lsp_version}'"
  end

  link '/usr/local/bin/kotlin-lsp' do
    to '/opt/kotlin-lsp/bin/kotlin-lsp'
    user 'root'
    force true
  end
end
