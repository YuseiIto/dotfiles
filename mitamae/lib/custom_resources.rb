# Symlink dotfiles to the user's home directory
define :dotfile, source: nil do
  # Use the resource name as the source file if not explicitly provided
  source_file = params[:source] || params[:name]

  link File.join(ENV['HOME'], params[:name]) do
    to File.expand_path("../../files/#{source_file}", File.dirname(@recipe.path))
    force true
  end
end
