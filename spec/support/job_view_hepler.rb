# -*- encoding : utf-8 -*-

module JobViewHelper
  def register_job_view_path
    controller.prepend_view_path Rails.root.join('lib', 'jobs', 'analysis',
                                                 'views')

    # RSpec isn't smart enough to read our routes for us, so set
    # things manually here.
    controller.controller_path = 'datasets'
    controller.request.path_parameters[:controller] = 'datasets'
  end
end
