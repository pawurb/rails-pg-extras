RailsPgExtras::Web::Engine.routes.draw do
  resources :queries, only: [:index]

  post "/actions/kill_all" => "actions#kill_all", as: :kill_all_action
  post "/actions/pg_stat_statements_reset" => "actions#pg_stat_statements_reset", as: :pg_stat_statements_reset_action
  post "/actions/add_extensions" => "actions#add_extensions", as: :add_extensions_action

  root to: "queries#index"
end
