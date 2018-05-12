# frozen_string_literal: true

Rails.application.routes.draw do
  # The user workflow
  get 'workflow' => 'workflow#index'
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
  get 'documents/:uid/citeulike' => 'documents#citeulike',
      as: 'documents_citeulike', constraints: { uid: /.*/ }

  # Datasets (per-user)
  resources :datasets, except: :edit do
    resources :tasks, module: 'datasets', path: 'tasks',
                      except: %i[edit update show] do
      member do
        get 'view/:template', action: 'view', as: 'view'
      end
    end
  end

  # User login routes
  devise_for :users,
             skip: [:sessions],
             controllers: { passwords: 'users/passwords' }
  devise_scope :user do
    # We only want users to sign in using the dropdown box on the main page,
    # not by visiting /users/sign_in, so we don't create a get 'sign_in' route
    # here.
    post 'users/sign_in' => 'devise/sessions#create', as: :user_session
    match 'users/sign_out' => 'devise/sessions#destroy',
          as: :destroy_user_session, via: Devise.mappings[:user].sign_out_via

    # User export manipulation
    get 'users/export' => 'users#export_create', as: :user_export
    delete 'users/export' => 'users#export_delete', as: ''

    # Redirect to the root after a successful user edit
    get 'users' => 'workflow#index'
  end

  scope '/users' do
    # Libraries, nested under users
    resources :libraries, module: 'users', except: :show do
      collection { get 'query' }
    end
  end

  # Static content
  get 'static/cookies' => 'static#cookies'
  post 'static/echo' => 'static#echo'
  get 'static/user_data' => 'static#user_data'

  # Administration pages
  get 'admin' => 'admin#index'
  get 'admin/login' => 'admin#login'
  post 'admin/login' => 'admin#login'
  delete 'admin/logout' => 'admin#logout'

  scope '/admin' do
    resources :categories, module: 'admin' do
      collection { post 'order' }
    end
    resources :stop_lists, module: 'admin', except: [:show]
    resources :snippets, module: 'admin', except: [:show]

    get 'assets' => 'admin/assets#index', as: :assets
    post 'asset/:id' => 'admin/assets#upload', as: :upload_asset
  end

  # unAPI service
  get 'unapi' => 'unapi#index'

  # List (autocomplete) service for the search pages
  get 'lists/authors' => 'lists#authors'
  get 'lists/journals' => 'lists#journals'

  # Start off on the landing/dashboard page
  root to: 'workflow#index'

  # Error pages
  get '/404' => 'errors#not_found'
  get '/422' => 'errors#unprocessable'
  get '/500' => 'errors#internal_error'
end
