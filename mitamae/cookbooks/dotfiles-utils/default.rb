# Repo-local dev tooling for this dotfiles repository itself.
# Currently: ensures `bundle exec rubocop` works against mitamae/Gemfile.
include_recipe '../ruby'

mitamae_dir = File.expand_path('../..', File.dirname(__FILE__))

# Read the bundler version pinned in Gemfile.lock once at recipe-eval time.
# Ruby ships a default bundler, so we must install the pinned version explicitly —
# otherwise `bundle install` fails with "Could not find 'bundler' (X.Y.Z) required
# by your Gemfile.lock".
gemfile_lock_lines = File.read("#{mitamae_dir}/Gemfile.lock").split("\n")
bundler_version = gemfile_lock_lines[gemfile_lock_lines.index('BUNDLED WITH') + 1].strip

execute "Install bundler #{bundler_version} (pinned in mitamae/Gemfile.lock)" do
  command "rbenv exec gem install bundler -v #{bundler_version} && rbenv rehash"
  not_if  "rbenv exec gem list -i bundler -v #{bundler_version} >/dev/null 2>&1"
end

execute 'bundle install for mitamae Gemfile' do
  command "cd #{mitamae_dir} && rbenv exec bundle install"
  not_if  "cd #{mitamae_dir} && rbenv exec bundle check >/dev/null 2>&1"
end
