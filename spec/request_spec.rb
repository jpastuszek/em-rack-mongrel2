require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'mongrel2/request'

describe Mongrel2::Request do
  it "should parse a Mongrel2 message" do
    message = "UUID CON PATH 253:{\"PATH\":\"/\",\"user-agent\":\"curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3\",\"host\":\"localhost:6767\",\"accept\":\"*/*\",\"connection\":\"close\",\"x-forwarded-for\":\"::1\",\"METHOD\":\"GET\",\"VERSION\":\"HTTP/1.1\",\"URI\":\"/\",\"PATTERN\":\"/\"},0:,"
    connection = double('connection')
    uuid = 'UUID'
    conn_id = 'CON'
    path = 'PATH'
    headers = {
      'PATH' => '/',
      'user-agent' => 'curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3',
      'host' => 'localhost:6767',
      'accept' => '*/*',
      'connection' => 'close',
      'x-forwarded-for' => '::1',
      'METHOD' => 'GET',
      'VERSION' => 'HTTP/1.1',
      'URI' => '/',
      'PATTERN' => '/'
    }
    body = double('body')
    StringIO.should_receive(:new).with('').and_return(body)
    request = double('request')
    Mongrel2::Request.should_receive(:new).with(uuid, conn_id, path, headers, body, connection).and_return(request)
    r = Mongrel2::Request.parse(message, connection)
    r.should eql(request)
  end

  it "should parse a Mongrel2 message and have all parts populated" do
    message = "UUID CON PATH 253:{\"PATH\":\"/\",\"user-agent\":\"curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3\",\"host\":\"localhost:6767\",\"accept\":\"*/*\",\"connection\":\"close\",\"x-forwarded-for\":\"::1\",\"METHOD\":\"GET\",\"VERSION\":\"HTTP/1.1\",\"URI\":\"/\",\"PATTERN\":\"/\"},0:,"
    r = Mongrel2::Request.parse(message, double())
    r.should_not be_nil
    r.uuid.should eql('UUID')
    r.conn_id.should eql('CON')
    r.path.should eql('PATH')
    r.body.length.should == 0
    r.headers.length.should == 10
    r.headers['PATH'].should eql('/')
    r.headers['user-agent'].should eql('curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3')
    r.headers['host'].should eql('localhost:6767')
    r.headers['accept'].should eql('*/*')
    r.headers['x-forwarded-for'].should eql('::1')
    r.headers['METHOD'].should eql('GET')
    r.headers['VERSION'].should eql('HTTP/1.1')
    r.headers['URI'].should eql('/')
    r.headers['PATTERN'].should eql('/')
    r.close?.should be_true
  end

  it "should return rack env with async callbacks" do
    message = "UUID CON PATH 253:{\"PATH\":\"/\",\"user-agent\":\"curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3\",\"host\":\"localhost:6767\",\"accept\":\"*/*\",\"connection\":\"close\",\"x-forwarded-for\":\"::1\",\"METHOD\":\"GET\",\"VERSION\":\"HTTP/1.1\",\"URI\":\"/\",\"PATTERN\":\"/\"},0:,"
    response = double("response")
    connection = double("connection")
    r = Mongrel2::Request.parse(message, connection)
    connection.should_receive(:post_process).with(response, r)
    env = r.env
    env['async.callback'].call(response)
    env['async.close'].should_not be_nil
  end

  it "should open an async uploaded file for body" do
    message = "UUID CON PATH 296:{\"PATH\":\"/\",\"user-agent\":\"curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3\",\"host\":\"localhost:6767\",\"accept\":\"*/*\",\"connection\":\"close\",\"x-forwarded-for\":\"::1\",\"METHOD\":\"GET\",\"VERSION\":\"HTTP/1.1\",\"URI\":\"/\",\"PATTERN\":\"/\",\"x-mongrel2-upload-done\":\"tmp/upload.file\"},0:,"
    response = double("response")
    connection = double("connection")
    connection.stub(:chroot).and_return('.')
    io = double('io')
    File.should_receive(:open).with('./tmp/upload.file').and_return(io)
    r = Mongrel2::Request.parse(message, connection)
    r.body.should eql(io)
  end
end
