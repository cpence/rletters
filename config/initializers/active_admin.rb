
ActiveAdmin.setup do |config|
  config.site_title = 'RLetters Backend'

  config.authentication_method = :authenticate_administrator!
  config.current_user_method = :current_administrator
  config.logout_link_path = :destroy_administrator_session_path

  config.batch_actions = true
  config.comments = false

  # Add a link to the job queue page from the ActiveAdmin menu
  config.namespace :admin do |admin|
    admin.build_menu do |menu|
      menu.add label: 'Job Queue', url: '/admin/jobs', priority: 100
    end
  end
end
