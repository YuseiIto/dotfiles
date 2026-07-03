include_recipe '../shell-env'

# Install zsh
cross_platform_package 'zsh'

dotfile '.zshenv' do
  cookbook_dir File.dirname(__FILE__)
end

dotfile '.zshrc' do
  cookbook_dir File.dirname(__FILE__)
end
