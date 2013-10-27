# -*- encoding : utf-8 -*-

# Configure sensitive parameters which will be filtered from the log file.
# These are converted to regular expressions before matching, so this is all
# that we need to have here.
Rails.application.config.filter_parameters += [:password]
