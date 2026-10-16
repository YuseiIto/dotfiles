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
      set -eu
      work_dir="$(mktemp -d)"
      trap 'rm -rf "$work_dir"' EXIT
      curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-#{aws_arch}.zip" -o "$work_dir/awscliv2.zip"
      unzip -qo "$work_dir/awscliv2.zip" -d "$work_dir"
      "$work_dir/aws/install" --update
    EOC
    user 'root'
    not_if 'command -v aws'
  end
else
  unsupported_platform! node[:platform]
end
