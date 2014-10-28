require 'socket'
require 'pry'

DOCUMENT_ROOT = File.expand_path("../",__FILE__)

#リクエストの処理(HTTPメソッド)
def handle_req(request)
  request[0].match(/(.+)\s\//)[1]
end

#パスの解析
def handle_path(request)
  path = request[0].match(/\s(\/.*)\sHTTP/)[1]
  path = "/test.html"
end

#レスポンスを返す
def return_response(socket,method,path)
  case method
    when /get/i
      File.open("#{DOCUMENT_ROOT}#{path}") do |f|
        socket.write("HTTP/1.1 200 OK\r\n")
        socket.write("Content-Type: text/html; charset=utf-8\r\n")
        socket.write("\r\n")
        socket.write(f.read)
      end
    when /post/i
     File.open("#{DOCUMENT_ROOT}#{path}") do |f|
       socket.write("HTTP/1.1 200 OK")
       socket.write("Connection: close")
       socket.write("Content-Type: text/html; charset=utf-8\r\n")
       socket.write("\r\n")
       socket.write(f.read)
     end
  end
end

#リクエストヘッダをまとめて扱う
def buffer_gets(socket)
  buffer = []
  while(buf = socket.gets)
    buffer.push(buf)
    break if buf == "\r\n"
  end
  return buffer
end

HOST,PORT = "localhost",8000
begin
  server = TCPServer.open(HOST,PORT)
  puts "クライアント接続待機"
  while true
    socket = server.accept
    request = buffer_gets(socket)
    #リクエスト表示
    puts request
    if request.size > 0
      method = handle_req(request)
      path = handle_path(request)
      return_response(socket,method,path)
    end
    socket.close
  end
  server.close
rescue => e
  puts e
  puts e.backtrace
end

