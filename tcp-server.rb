require "socket"

#ポート番号8000でopen
server = TCPServer.open(8000);
while true
  #クライアントからの接続を待つ
  puts "クライアントからの接続を待ちます"
  sock = server.accept
  #接続相手の情報を得る
  puts "接続相手の情報:[アドレスファミリ, port番号, ホストを表す文字列, IPアドレス]"
  p sock.peeraddr
  #クライアントからのデータを最後まで受信する
  #受信したデータはコンソールに表示される
  while buf = sock.gets
    p buf
  end
  #クライアントとの接続ソケットを閉じる
  sock.close
end

#待ち受けソケットを閉じる
server.close
