MindpinEduSns::Application.routes.draw do
  root :to => 'index#index'

  post '/operate_project' => 'index#operate_project'
  post '/operate_server'  => 'index#operate_server'
  
  get '/redis_stats'     => 'index#redis_stats'
  post '/redis_flushall'    => 'index#redis_flushall'
  post '/redis_cache_flush' => 'index#redis_cache_flush'
  post '/redis_tip_flush'   => 'index#redis_tip_flush'
  post '/redis_queue_flush' => 'index#redis_queue_flush'

  get '/project_log' => 'index#project_log'
  get '/server_log' => 'index#server_log'

  get  '/login'    => 'index#login'
  post '/do_login' => 'index#do_login'
  get  '/logout'   => 'index#logout'
end
