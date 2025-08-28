Rails.application.routes.draw do
  # 🔹 一般ユーザー向け
  resources :onsens, only: %i[index show] do
    resources :reviews, only: %i[create new]
  end

  # 🔹 管理画面
  namespace :admin do
    root "onsens#index"

    # セッション（ログイン関連）
    get    "login",  to: "sessions#new"
    post   "login",  to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    resources :onsens
  end

  # 🔹 ヘルスチェック (Rails標準)
  get "up" => "rails/health#show", as: :rails_health_check

  # 🔹 PWA 関連 (コメントアウトのまま)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # 🔹 ルート（一般ユーザー向けTOP）
  root "onsens#index"
end
