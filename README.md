# em-rack-mongrel2

This is a Mongrel2 Rack handler that supports EventMachine and async response.

I folked this from darkhelmet's rack-mongrel2 so that I can rack up async_sinatra apps.
Tested on async_sinatra but will be able to run any Rack apps that requires an async web server such as Thin.

This is my very first contribution to Ruby ecosystem. Let me know if I've done wrong.
Pull requests and feature requests are very welcome!

## How to run examples

Clone the repository.

    git clone https://github.com/ichiban/em-rack-mongrel2.git

Download all dependencies.

    cd em-rack-mongrel2
    bundle install

Run Mongrel2.

    cd example
    mkdir -p tmp/pids logs
    m2sh load
    m2sh start -name main

Run a simple sinatra example or

    cd sinatra
    export RACK_MONGREL2_SEND=tcp://127.0.0.1:9996
    export RACK_MONGREL2_RECV=tcp://127.0.0.1:9997
    export RACK_MONGREL2_UUID=9539ED88-1B33-4D19-A9F9-283E5BF11AC7
    rackup -s Mongrel2

Run an async sinatra example.

    cd async_sinatra
    export RACK_MONGREL2_SEND=tcp://127.0.0.1:9998
    export RACK_MONGREL2_RECV=tcp://127.0.0.1:9999
    export RACK_MONGREL2_UUID=AEE66029-E420-42E7-A7C8-6C37BBFC7B9F
    rackup -s Mongrel2

## How to use in your projects

1. Get mongrel2 installed (http://mongrel2.org/wiki/quick_start.html)
1. Get your config for mongrel2 setup (see example directory)
1. Add it to your Gemfile (gem 'em-rack-mongrel2', '~> 0.1.0')
1. You also need some sort of JSON parsing library installed, like Yajl or JSON (gem i yajl-ruby or gem i json). json-jruby will work too
1. Run Mongrel2
1. Run your rack application

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

* Original project Copyright (c) 2010, 2011 Daniel Huckstep. See LICENSE for details.
* This derivative project Copyright (c) 2011 ICHIBANGASE, Yutaka.
