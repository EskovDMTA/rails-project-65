# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  scope module: 'web' do
    root 'bulletins#index'
    post 'auth/:provider', to: 'auth#request', as: :auth_request
    delete 'auth/logout', to: 'auth#destroy'
    get 'auth/:provider/callback', to: 'auth#callback', as: :callback_auth
    resources :bulletins, except: %i[destroy] do
      member do
        post :submit_for_moderation
        patch :archive
      end
    end
    resource :profile, only: %i[show]

    namespace :admin do
      root 'home#index'
      resources :bulletins, only: :index do
        member do
          post :approve
          patch :archive
          patch :publish
          patch :reject
        end
      end
      resources :categories
    end
  end
end
