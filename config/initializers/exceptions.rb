# -*- encoding : utf-8 -*-

# Bounce exceptions to the routing system
Rails.application.config.exceptions_app = Rails.application.routes
