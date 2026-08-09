# Arm GNU Toolchain for bare-metal 32-bit Arm targets.
#
# Arm's own prebuilt pkg, via homebrew-cask. Two rejected alternatives:
#
# - homebrew-core's `arm-none-eabi-gcc` is configured `--without-headers` and
#   core ships no newlib, so it produces a freestanding compiler with no
#   libc.a / nosys.specs. Linking a normal bare-metal project against it fails.
# - `armmbed/formulae` pins 10.3-2021.10 and has had no commit since 2023-09;
#   its own README points here as the replacement.
if node[:platform] == 'darwin'
  brew_cask 'gcc-arm-embedded'
else
  unsupported_platform! node[:platform]
end
