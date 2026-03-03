if %w[ubuntu debian].include?(node[:platform])
  package 'git' do
    user 'root'
  end
else
  # macOS, Arch Linux
  package 'git'
end

home = ENV['HOME']
repo_root = File.expand_path('../../..', File.dirname(__FILE__))

directory "#{home}/.config"

link "#{home}/.config/git" do
  to "#{repo_root}/.config/git"
  force true
end
