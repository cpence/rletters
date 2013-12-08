# -*- encoding : utf-8 -*-

RLetters::Application.routes.draw do

  # The user workflow
  get 'workflow' => 'workflow#index'
  get 'workflow/image/:id' => 'workflow#image', as: 'workflow_image'
  get 'workflow/start' => 'workflow#start'
  get 'workflow/destroy' => 'workflow#destroy'
  get 'workflow/info/:class' => 'workflow#info', as: 'workflow_info',
      constraints: { class: /[A-Z][A-Za-z]+/ }
  get 'workflow/activate/:class' => 'workflow#activate',
      as: 'workflow_activate', constraints: { class: /[A-Z][A-Za-z]+/ }
  get 'workflow/fetch' => 'workflow#fetch'

  # Search/Browse page
  get 'search' => 'search#index'
  get 'search/advanced' => 'search#advanced'

  # Documents
  get 'documents/:uid/export' => 'documents#export',
      as: 'documents_export', constraints: { uid: /.*/ }
  get 'documents/:uid/mendeley' => 'documents#mendeley',
      as: 'documents_mendeley', constraints: { uid: /.*/ }
  get 'documents/:uid/citeulike' => 'documents#citeulike',
      as: 'documents_citeulike', constraints: { uid: /.*/ }

  # Datasets (per-user)
  resources :datasets, except: :edit do
    resources :analysis_tasks, module: 'datasets',
                               path: 'tasks',
                               except: [:edit, :update]
  end

  # User login routes
  devise_for :users, skip: [:sessions]
  as :user do
    # We only want users to sign in using the dropdown box on the main page,
    # not by visiting /users/sign_in, so we don't create a get 'sign_in' route
    # here.
    post 'users/sign_in' => 'devise/sessions#create', as: :user_session
    if Rails.env.test?
      get 'users/sign_out' => 'devise/sessions#destroy',
          as: :destroy_user_session
    else
      delete 'users/sign_out' => 'devise/sessions#destroy',
             as: :destroy_user_session
    end

    # Redirect to the root after a successful user edit
    get 'users' => 'workflow#index'
  end

  scope '/users' do
    # Libraries, nested under users
    resources :libraries, module: 'users', except: :show do
      collection do
        get 'query'
      end
    end
  end

  # Administration pages
  ActiveAdmin.routes(self)
  devise_for :administrators, ActiveAdmin::Devise.config.merge(class_name: 'Admin::Administrator')
  authenticate :administrator do
    mount Resque::Server.new, at: '/admin/jobs'
  end

  # unAPI service
  get 'unapi' => 'unapi#index'

  # Start off on the landing/dashboard page
  root to: 'workflow#index'

  # Error pages
  get '/404' => 'errors#not_found'
  get '/422' => 'errors#unprocessable'
  get '/500' => 'errors#internal_error'
end
