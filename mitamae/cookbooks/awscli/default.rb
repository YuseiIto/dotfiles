if node[:platform] == 'darwin'
  package 'awscli'
elsif %w[ubuntu debian].include?(node[:platform])
  package 'unzip' do
    user 'root'
  end

  # AWS ships the installer under aarch64/x86_64; map from the normalized
  # node[:os_arch] instead of re-deriving the arch with a shell `uname -m` case.
  aws_arch = node[:os_arch] == 'arm64' ? 'aarch64' : 'x86_64'

  execute 'Install AWS CLI v2' do
    command <<~EOC
      curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-#{aws_arch}.zip" -o /tmp/awscliv2.zip
      cd /tmp && unzip -qo awscliv2.zip
      /tmp/aws/install --update
      rm -rf /tmp/awscliv2.zip /tmp/aws
    EOC
    user 'root'
    not_if 'command -v aws'
  end
else
  unsupported_platform! node[:platform]
end
