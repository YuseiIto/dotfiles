# cargo-lambda: build, test, and deploy AWS Lambda functions written in Rust.
#
# cargo-lambda is a Rust crate, but `cargo install cargo-lambda` compiles a huge
# dependency tree (aws-sdk, gix, watchexec, ...) from source and runs the CI
# containers out of disk ("No space left on device"). Upstream also publishes
# prebuilt binary wheels to PyPI (built with maturin), so install it with uv
# instead: no compilation, tiny footprint, and it tracks the latest release.
#
# It runs as a Cargo subcommand (`cargo lambda`), so it still needs cargo on
# PATH; depend on the rust cookbook.
include_recipe File.expand_path('../rust', File.dirname(__FILE__))

uv_tool_package 'cargo-lambda'
