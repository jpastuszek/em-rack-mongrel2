require 'sinatra'
require 'yajl/json_gem'

get '/' do
  sleep 1
  request.env.to_json
end
