# frozen_string_literal: true

module Admin
  module AssetHelper
    # If an asset is usable, yield a URL for it to a block
    #
    # @param [String] name the name of the asset to find
    # @yieldparam [String] url the URL for the asset, if it is available
    # @return [void]
    def with_asset(name)
      return unless Admin::Asset.usable?(name)

      asset = Admin::Asset.find_by!(name: name)
      yield url_for(asset.file), asset.file.content_type
    end
  end
end
