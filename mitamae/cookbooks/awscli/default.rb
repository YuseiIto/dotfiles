if node[:platform] == 'darwin'
  package 'awscli'
elsif %w[ubuntu debian].include?(node[:platform])
  # gnupg dearmors the pinned key; gpgv checks the installer signature.
  %w[unzip gnupg gpgv].each do |pkg|
    package pkg do
      user 'root'
    end
  end

  # AWS ships the installer under aarch64/x86_64; map from the normalized
  # node[:os_arch] instead of re-deriving the arch with a shell `uname -m` case.
  aws_arch = node[:os_arch] == 'arm64' ? 'aarch64' : 'x86_64'
  installer_url = "https://awscli.amazonaws.com/awscli-exe-linux-#{aws_arch}.zip"

  # NOTE: The installer is unversioned and signed rather than checksummed, so
  # pin AWS's signing key (FB5D B77F D5C1 18B8 0511 ADA8 A631 0ACC 4672 475C).
  # gpgv ignores key expiry; a rotated key fails the install until replaced.
  # Ref: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
  public_key = File.join(File.dirname(__FILE__), 'files', 'aws-cli-team.asc')

  execute 'Install AWS CLI v2' do
    command <<~EOC
      set -eu
      work_dir="$(mktemp -d)"
      trap 'rm -rf "$work_dir"' EXIT
      curl -fsSL "#{installer_url}" -o "$work_dir/awscliv2.zip"
      curl -fsSL "#{installer_url}.sig" -o "$work_dir/awscliv2.zip.sig"
      gpg --homedir "$work_dir" --dearmor < "#{public_key}" > "$work_dir/aws-cli-team.gpg"
      gpgv --homedir "$work_dir" --keyring "$work_dir/aws-cli-team.gpg" "$work_dir/awscliv2.zip.sig" "$work_dir/awscliv2.zip"
      unzip -qo "$work_dir/awscliv2.zip" -d "$work_dir"
      "$work_dir/aws/install" --update
    EOC
    user 'root'
    not_if 'command -v aws'
  end
else
  unsupported_platform! node[:platform]
end
