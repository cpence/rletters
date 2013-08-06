# -*- encoding : utf-8 -*-

RLetters::Application.routes.draw do

  # Static information pages
  get 'info' => 'info#index'
  get 'info/about' => 'info#about'
  get 'info/faq' => 'info#faq'
  get 'info/privacy' => 'info#privacy'
  get 'info/tutorial' => 'info#tutorial'

  # Search/Browse page
  get 'search' => 'search#index'
  get 'search/advanced' => 'search#advanced'
  get 'search/document/:id' => 'search#show',
      as: 'search_show'
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
  devise_for :users

  # Redirect to the main user page after a successful user edit
  devise_scope :user do
    get 'users' => 'info#index', as: :user_root
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

  # unAPI service
  get 'unapi' => 'unapi#index'

  # Start off on the info/home page
  root to: 'info#index'

  # Error pages
  get '/404' => 'errors#not_found'
  get '/422' => 'errors#unprocessable'
  get '/500' => 'errors#internal_error'
end
