home = ENV['HOME']
directory "#{home}/.config"
directory "#{home}/.config/nvim"
directory "#{home}/.config/nvim/lua"

# Roleで定義されたフラグを元に features.lua を生成
template "#{home}/.config/nvim/lua/features.lua" do
  source 'templates/features.lua.erb'
  variables(
    editor_features: node[:editor_features]
  )
end
