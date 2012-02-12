require 'sinatra'
require 'sinatra/async'
require 'yajl/json_gem'

class AsyncExample < Sinatra::Base
  register Sinatra::Async

  aget '/' do
    EM.add_timer(1) do
      body request.env.to_json
    end
  end
end

