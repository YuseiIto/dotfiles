require 'English'
require 'json'

# Bitwarden CLI integration module.
# Provides methods to check vault status and retrieve secrents.
module Bitwarden
  class << self
    # Check if Bitwarden CLI is available and the vault is unlocked.
    def unlocked?
      return @unlocked if defined?(@unlocked)

      has_cmd = system('command -v bw > /dev/null 2>&1')
      if has_cmd
        status_json = `bw status 2>/dev/null`
        @unlocked = $CHILD_STATUS.success? && status_json.include?('"status":"unlocked"')
      else
        @unlocked = false
      end
      @unlocked
    end

    # Password item retrieval with caching. Returns nil if not found or vault is locked.
    def get_item(item_name)
      return nil unless unlocked?

      @cache ||= {}
      return @cache[item_name] if @cache.key?(item_name)

      json_str = `bw get item "#{item_name}" 2>/dev/null`
      @cache[item_name] = (JSON.parse(json_str) if $CHILD_STATUS.success?)
    end

    # Notes retrieval helper
    def get_notes(item_name)
      item = get_item(item_name)
      item ? item['notes'] : nil
    end

    # Custom field retrieval helper
    def get_custom_field(item_name, field_name)
      item = get_item(item_name)
      return nil unless item && item['fields']

      field = item['fields'].find { |f| f['name'] == field_name }
      field ? field['value'] : nil
    end
  end
end
