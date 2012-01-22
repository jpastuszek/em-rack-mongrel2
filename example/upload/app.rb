require 'sinatra'
require 'yajl/json_gem'
require 'pp'

set(:mongrel2_upload) do |value|
  condition do
    case value
    when :start
      request.env.key?('HTTP_X_MONGREL2_UPLOAD_START')
    when :done
      request.env.key?('HTTP_X_MONGREL2_UPLOAD_DONE')
    else
      false
    end
  end
end

before do
  pp request
end

put '/ok', :mongrel2_upload => :done do
  'upload done'
end

put '/ok', :mongrel2_upload => :start do
  throw :async # continue the upload
end

put '/ng', :mongrel2_upload => :done do
  'this will never happen'
end

put '/ng', :mongrel2_upload => :start do
  '' # cancel the upload
end
