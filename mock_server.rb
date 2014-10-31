require 'socket'
require 'pry'
require './request.rb'
require './response.rb'

#TCPサーバーをオープン
server = TCPServer.open("localhost",8000)
#クライアントの接続を待ち受ける
loop do
    socket = server.accept
    #クライアントからの入力を格納する
    request = Request.new(socket)
    puts request
    #リクエストに応じる
    response = Responce.new(socket,request)
    #ソケットを閉じる
    socket.close
end
#TCPサーバーをクローズする
server.close
