Rails.application.routes.draw do
  devise_for :users
  resources :keyword_mappings

  resources :push_messages, only: [:new, :create]

  get '/kamigo/send_request', to: 'kamigo#send_request'
  post '/kamigo/webhook', to: 'kamigo#webhook'

  get '/kamigo/eat', to: 'kamigo#eat'

  get '/kamigo/request_headers', to: 'kamigo#request_headers'
  get '/kamigo/request_body', to: 'kamigo#request_body'

  get '/kamigo/response_headers', to: 'kamigo#response_headers'
  get '/kamigo/response_body', to: 'kamigo#show_response_body'
end
