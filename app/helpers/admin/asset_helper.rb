# frozen_string_literal: true

module Admin
  module AssetHelper
    # If an asset is usable, yield a URL for it to the provided block
    def with_asset(name, &block)
      return unless Admin::Asset.usable?(name)

      asset = Admin::Asset.find_by!(name: name)
      yield url_for(asset.file), asset.file.content_type
    end
  end
end
