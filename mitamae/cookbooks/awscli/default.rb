if node[:platform] == 'darwin'
  package 'awscli'
elsif %w[ubuntu debian].include?(node[:platform])
  package 'unzip' do
    user 'root'
  end

  execute 'Install AWS CLI v2' do
    command <<~EOC
      arch=$(uname -m)
      case "$arch" in
        aarch64|arm64) arch="aarch64" ;;
        x86_64|amd64) arch="x86_64" ;;
      esac
      curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" -o /tmp/awscliv2.zip
      cd /tmp && unzip -qo awscliv2.zip
      /tmp/aws/install --update
      rm -rf /tmp/awscliv2.zip /tmp/aws
    EOC
    user 'root'
    not_if 'command -v aws'
  end
end
