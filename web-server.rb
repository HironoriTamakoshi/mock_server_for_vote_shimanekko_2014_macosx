require 'socket'
require 'pry'

=begin
class Controller
  def login_check(email,password)
    db_data.each do |data|
      return true and if (data[0] == email && data[1] == password)
    end
  end

  def db_data
    File.open(DOCUMENT_ROOT+"/db.txt") do |f|
      check_db = f.to_a.map{|data|data.chomp.split(":")}
    end
  end
end
=end

DOCUMENT_ROOT = File.expand_path("../",__FILE__)

#リクエストの処理(HTTPメソッド)
def handle_req(request)
  request[0].match(/(.+)\s\//)[1]
end

#パスの解析
def handle_path(request)
  path = request[0].match(/\s(\/.*)\sHTTP/)[1]
  if path.include?("php") || path == "/" || path == "/favicon.ico"
    path = "/test.html"
  else
    path
  end

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
  if 
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

