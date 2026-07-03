include_recipe '../claude-code'

cookbook_dir = File.dirname(__FILE__)
script_src = File.join(cookbook_dir, 'files', 'git-commit-claude')
bin_dir = "#{ENV['HOME']}/.local/bin"
script_dest = "#{bin_dir}/git-commit-claude"
alias_dest = "#{bin_dir}/git-ccc"

directory bin_dir

link script_dest do
  to script_src
  force true
end

link alias_dest do
  to script_dest
  force true
end
