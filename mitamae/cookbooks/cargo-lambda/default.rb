# It runs as a Cargo subcommand (`cargo lambda`), so it still needs cargo on
# PATH; depend on the rust cookbook.
include_recipe File.expand_path('../rust', File.dirname(__FILE__))

uv_tool_package 'cargo-lambda'
