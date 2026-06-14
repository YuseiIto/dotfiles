# cargo-lambda: build, test, and deploy AWS Lambda functions written in Rust.
#
# It ships as a Cargo subcommand (invoked as `cargo lambda`) and is published on
# crates.io, so the shared cargo_package helper installs it identically on macOS
# and Debian/Ubuntu and pulls in the rust cookbook as a dependency. The crate
# name matches the resulting binary (`cargo-lambda`), so no bin_name override is
# needed.
cargo_package 'cargo-lambda'
