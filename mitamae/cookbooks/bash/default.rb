include_recipe '../shell-env'

dotfile '.bashrc' do
  cookbook_dir File.dirname(__FILE__)
end

dotfile '.bash_profile' do
  cookbook_dir File.dirname(__FILE__)
end
