raise "unsupported platform #{node[:platform]}: #{__FILE__}:#{__LINE__}" unless node[:platform] == 'darwin'

package 'arm-none-eabi-gcc'
