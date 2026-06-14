# cargo-lambda: build, test, and deploy AWS Lambda functions written in Rust.
#
# cargo-lambda is a Rust crate, but `cargo install cargo-lambda` compiles a huge
# dependency tree (aws-sdk, gix, watchexec, ...) from source and runs the CI
# containers out of disk ("No space left on device"). Install the prebuilt
# release binary instead -- it is small and fast on every platform.
#
# It runs as a Cargo subcommand (`cargo lambda`), so it still needs cargo on
# PATH: depend on the rust cookbook and drop the binary into ~/.cargo/bin, which
# rust already creates, exports on PATH, and goss validation picks up.
include_recipe File.expand_path('../rust', File.dirname(__FILE__))

version = '1.9.1' # Latest release -- verify against github.com/cargo-lambda/cargo-lambda/releases
home = ENV['HOME']
arch = node[:os_arch] == 'arm64' ? 'aarch64' : 'x86_64'

target =
  if node[:platform] == 'darwin'
    "#{arch}-apple-darwin"
  elsif %w[ubuntu debian].include?(node[:platform])
    # musl builds are statically linked, so they run on any glibc version.
    "#{arch}-unknown-linux-musl"
  else
    unsupported_platform! node[:platform]
  end

archive = "cargo-lambda-v#{version}.#{target}.tar.gz"
url = "https://github.com/cargo-lambda/cargo-lambda/releases/download/v#{version}/#{archive}"

execute "install cargo-lambda #{version}" do
  command <<~INSTALL
    set -e
    tmp="$(mktemp -d)"
    curl -fsSL "#{url}" -o "$tmp/#{archive}"
    tar xzf "$tmp/#{archive}" -C "$tmp"
    bin="$(find "$tmp" -type f -name cargo-lambda | head -n 1)"
    install -m 0755 "$bin" "#{home}/.cargo/bin/cargo-lambda"
    rm -rf "$tmp"
  INSTALL
  not_if "cargo lambda --version 2>/dev/null | grep -q '#{version}'"
end
