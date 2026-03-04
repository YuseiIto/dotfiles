# Symlink dotfiles to the user's home directory
define :dotfile, source: nil do
  # Use the resource name as the source file if not explicitly provided
  source_file = params[:source] || params[:name]

  link File.join(ENV['HOME'], params[:name]) do
    to File.expand_path("files/#{source_file}", File.dirname(@recipe.path))
    force true
  end
end

# Symlink configuration files to the user's .config directory
# Source files are resolved from the repository root's .config/ directory.
define :dotconfig, source: nil do
  # Use the resource name as the source file if not explicitly provided
  source_file = params[:source] || params[:name]
  config_dir = File.join(ENV['HOME'], '.config')

  # Ensure .config directory exists
  directory config_dir

  link File.join(config_dir, params[:name]) do
    to File.expand_path("../../../.config/#{source_file}", File.dirname(@recipe.path))
    force true
  end
end
