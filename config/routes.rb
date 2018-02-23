Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'jobs#summary'

  resources :jobs, only: [] do
    collection do
      get :summary
    end
  end
end
