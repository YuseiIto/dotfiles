raise "unsupported platform #{node[:platform]}: #{__FILE__}:#{__LINE__}" unless node[:platform] == 'darwin'

package 'tomoyanonymous/homebrew-flatcam/flatcam-evo'
