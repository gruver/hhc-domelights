Web::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  get 'lights' => 'lights#index', :as => :lights_index
  root :to => 'lights#index'
end
