if node[:platform] == 'darwin'
  execute 'Install Homebrew' do
    command 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    not_if 'command -v brew'
  end
end
