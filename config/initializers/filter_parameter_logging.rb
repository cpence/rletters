# -*- encoding : utf-8 -*-

# Filter out anything matching 'password' as well as the large binary blob
# columns 'file_contents'.
Rails.application.config.filter_parameters += [:password, :file_contents]
