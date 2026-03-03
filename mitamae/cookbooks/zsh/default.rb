# Install zsh
if node[:platform] == 'darwin'
  package 'zsh'
elsif node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  package 'zsh' do
    user 'root'
  end
end

# Symlink ".zshrc" to
cookbook_dir = File.expand_path('.', File.dirname(__FILE__))
home = ENV['HOME']

link "#{home}/.zshrc" do
  to File.join(cookbook_dir, 'files', '.zshrc')
  force true
end
