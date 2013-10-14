# -*- encoding : utf-8 -*-

RLetters::Application.routes.draw do

  # The user workflow
  get 'workflow' => 'workflow#index'
  get 'workflow/start' => 'workflow#start'
  get 'workflow/info/:class' => 'workflow#info', as: 'workflow_info',
    constraints: { class: /[A-Z][A-Za-z]+/ }
  get 'workflow/image/:id' => 'workflow#image', as: 'workflow_image'

  # Search/Browse page
  get 'search' => 'search#index'
  get 'search/advanced' => 'search#advanced'
  get 'search/document/:id/export' => 'search#export',
      as: 'search_export'
  get 'search/document/:id/add' => 'search#add',
      as: 'search_add'
  get 'search/document/:id/mendeley' => 'search#to_mendeley',
      as: 'mendeley_redirect'
  get 'search/document/:id/citeulike' => 'search#to_citeulike',
      as: 'citeulike_redirect'

  # Datasets (per-user)
  resources :datasets, except: [:edit, :update] do
    collection do
      get 'dataset_list'
      get 'add' => 'datasets#add', as: 'add_to'
    end

    member do
      get 'task_list'
      get 'delete'
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
    delete 'users/sign_out' => 'devise/sessions#destroy', as: :destroy_user_session

    # Redirect to the root after a successful user edit
    get 'users' => 'workflow#index'
  end

  scope '/users' do
    # Libraries, nested under users
    resources :libraries, except: :show do
      member do
        get 'delete'
      end
      collection do
        get 'query'
      end
    end
  end

  # Administration pages
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config
  authenticate :admin_user do
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
