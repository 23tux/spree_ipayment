Spree::Core::Engine.routes.draw do
  resources :orders do
    resource :checkout, :controller => 'checkout' do
      member do
        get :ipayment_success, :ipayment_confirm, :ipayment_error
        post :ipayment_finalize
      end
    end
  end
end
