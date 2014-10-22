require "socket"

#127.0.0.1(localhost)の8000番へ接続
begin
  sock = TCPSocket.open("127.0.0.1",8000)
rescue
  puts "TCP socket open failed"
else
#Helloという文字列を送信
sock.write("Hello")

#送信が終わったらソケットを閉じる
sock.close
end
