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
  get 'search/document/export' => 'search#export',
      as: 'search_export', constraints: ->(req) { req.params[:uid].present? }
  get 'search/document/add' => 'search#add',
      as: 'search_add', constraints: ->(req) { req.params[:uid].present? }
  get 'search/document/mendeley' => 'search#to_mendeley',
      as: 'mendeley_redirect', constraints: ->(req) { req.params[:uid].present? }
  get 'search/document/citeulike' => 'search#to_citeulike',
      as: 'citeulike_redirect', constraints: ->(req) { req.params[:uid].present? }

  # Datasets (per-user)
  resources :datasets, except: [:edit, :update] do
    collection do
      get 'dataset_list'
      get 'add' => 'datasets#add', as: 'add_to'
    end

    member do
      get 'task_list'
      get 'task/:class/start' => 'datasets#task_start',
          constraints: { class: /[A-Z][A-Za-z]+/ }
      get 'task/:class/view/:view' => 'datasets#task_view',
          constraints: { class: /[A-Z][A-Za-z]+/ }
      get 'task/:task_id/view/:view' => 'datasets#task_view',
          constraints: { task_id: /[0-9]+/ }
      get 'task/:task_id/destroy' => 'datasets#task_destroy',
          constraints: { task_id: /[0-9]+/ }
      get 'task/:task_id/download' => 'datasets#task_download',
          constraints: { task_id: /[0-9]+/ }
    end
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
