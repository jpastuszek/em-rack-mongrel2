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
    mkdir -p tmp/pids logs run
    m2sh load
    sudo m2sh start -name main

Run a simple sinatra example,

    cd sinatra
    rackup -s Mongrel2 \
     	   -O uuid=9539ED88-1B33-4D19-A9F9-283E5BF11AC7 \
     	   -O send=tcp://127.0.0.1:9996 \
     	   -O recv=tcp://127.0.0.1:9997

an async sinatra example or

    cd async_sinatra
    rackup -s Mongrel2 \
     	   -O uuid=AEE66029-E420-42E7-A7C8-6C37BBFC7B9F \
     	   -O send=tcp://127.0.0.1:9998 \
     	   -O recv=tcp://127.0.0.1:9999

a big-upload example.

    cd upload
    rackup -s Mongrel2 \
     	   -O uuid=51226E47-AE49-4BC8-A9C6-BD7F6827E8A4 \
     	   -O send=tcp://127.0.0.1:10000 \
     	   -O recv=tcp://127.0.0.1:10001 \
     	   -O chroot=..

## How to use in your projects

1. Get mongrel2 installed (http://mongrel2.org/wiki/quick_start.html)
1. Get your config for mongrel2 setup (see example directory)
1. Add it to your Gemfile (gem 'em-rack-mongrel2')
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
